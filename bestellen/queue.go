package main

import (
	"context"
	"encoding/json"
	"github.com/rabbitmq/amqp091-go"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"log"
	"math/rand/v2"
	"time"
)

// Extends Server

// MoveOrderToKitchen moves newly created orders to the kitchen.
// In a real implementation this would happen over the eventbus.
func (s *Server) MoveOrderToKitchen() error {
	ctx, cancel := context.WithTimeout(context.Background(), s.eventHandlerTimeout)
	defer cancel()
	filter := bson.D{
		// The bson serializer of mongodb writes an integer 0 as nil
		// into MongoDB. The reason for this is unclear.
		{"Status", nil},
	}
	collection := s.db.Collection(OrdersCollection)
	result, err := collection.Find(ctx, filter)
	if err != nil {
		return err
	}
	var createdOrders []Order
	err = result.All(ctx, &createdOrders)
	if err != nil {
		return err
	}
	for _, order := range createdOrders {
		go func(o Order) {
			ctx, cancel := context.WithTimeout(context.Background(), s.eventHandlerTimeout)
			defer cancel()
			update := bson.D{
				{"$set",
					bson.D{{"Status", StatusKitchen}},
				},
			}
			if _, err := collection.UpdateByID(ctx, o.ID, update); err != nil {
				log.Println("Cannot update order to kitchen state.", o.ID, "-", err)
			} else {
				log.Println("Order", o.ID, "is now in kitchen.")
			}
		}(order)
	}
	return nil
}

// MoveOrderToDelivery simulates the kitchen. Orders are marked as ready to delivery after 10-30 seconds,
// and are put onto the event q.
// In a real implementation the kitchen would mark them as ready, and the kitchen service would move them to the
// event bus.
func (s *Server) MoveOrderToDelivery() error {
	ch, err := s.q.Channel()
	if err != nil {
		return err
	}
	q, err := ch.QueueDeclare(
		s.qToDelivery,
		false, false,
		false, false,
		make(amqp091.Table),
	)
	_ = q
	if err != nil {
		return err
	}
	ctx, cancel := context.WithTimeout(context.Background(), s.eventHandlerTimeout)
	defer cancel()
	filter := bson.D{
		{"Status", StatusKitchen},
	}
	collection := s.db.Collection(OrdersCollection)
	result, err := collection.Find(ctx, filter)
	if err != nil {
		return err
	}
	var ordersInKitchen []Order
	err = result.All(ctx, &ordersInKitchen)
	if err != nil {
		return err
	}

	for _, order := range ordersInKitchen {
		go func(o Order) {
			time.Sleep(time.Duration(rand.IntN(20)+10) * time.Second)
			ctx, cancel := context.WithTimeout(context.Background(), s.eventHandlerTimeout)
			defer cancel()

			data, err := json.Marshal(o.ToDelivery())
			if err != nil {
				log.Println("Cannot marshal delivery: ", err)
				return
			}

			err = ch.PublishWithContext(ctx, "", s.qToDelivery, false, false, amqp091.Publishing{
				ContentType: "application/json",
				Body:        data,
				Type:        "orders.deliveries.new",
			})
			if err != nil {
				log.Println("Cannot publish delivery: ", err)
				return
			}

			update := bson.D{
				{"$set",
					bson.D{{"Status", StatusDelivery}},
				},
			}
			if _, err := collection.UpdateByID(ctx, o.ID, update); err != nil {
				log.Println("Cannot update order to delivery state.", o.ID, "-", err)
			} else {
				log.Println("Order", o.ID, "is getting delivered.")
			}
		}(order)
	}

	return nil
}

// ReceiveDeliveries updates the orders if they were delivered.
func (s *Server) ReceiveDeliveries() error {
	collection := s.db.Collection(OrdersCollection)

	ctx, cancel := context.WithTimeout(context.Background(), s.eventHandlerTimeout)
	defer cancel()
	ch, err := s.q.Channel()
	if err != nil {
		return err
	}
	q, err := ch.QueueDeclare(
		s.qFromDelivery,
		false, false,
		false, false,
		make(amqp091.Table),
	)
	_ = q
	if err != nil {
		return err
	}
	deliveries, err := ch.ConsumeWithContext(
		ctx,
		s.qFromDelivery,
		"",
		true,
		false,
		false,
		false,
		nil,
	)
	if err != nil {
		return err
	}

	for delivery := range deliveries {
		delivered := Delivered{}
		err := json.Unmarshal(delivery.Body, &delivered)
		if err != nil {
			log.Println("Cannot unmarshal delivery: ", err, delivery.Body)
			continue
		}
		update := bson.D{
			{"$set",
				bson.D{{"Status", StatusDelivered}},
			},
		}
		oid, _ := primitive.ObjectIDFromHex(delivered.Order.Id)
		if _, err := collection.UpdateByID(ctx, oid, update); err != nil {
			log.Println("Cannot update order to delivered state.", delivered.Order.Id, "-", err)
		} else {
			log.Println("Order", delivered.Order.Id, " was delivered.")
		}
	}
	return nil
}
