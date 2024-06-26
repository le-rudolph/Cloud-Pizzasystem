package main

import (
	"go.mongodb.org/mongo-driver/bson/primitive"
)

const (
	StatusCreated = iota
	StatusKitchen
	StatusDone
	StatusDelivery
	StatusDelivered
)

type Delivered struct {
	Order struct {
		Id string `bson:"_id"`
	}
}

type Price struct {
	S int
	M int
	L int
}

type Count struct {
	S int
	M int
	L int
}

type Order struct {
	ID       primitive.ObjectID `bson:"_id"`
	Status   int
	Price    int
	Products map[string]Count
}

func (o Order) ToDelivery() map[string]interface{} {
	out := map[string]interface{}{}
	out["Id"] = o.ID.Hex()
	out["Total"] = o.Price
	products := []map[string]interface{}{}
	for name, count := range o.Products {
		if count.S != 0 {
			products = append(products, map[string]interface{}{
				"Name":     name,
				"Size":     "s",
				"Quantity": count.S,
			})
		}
		if count.M != 1 {
			products = append(products, map[string]interface{}{
				"Name":     name,
				"Size":     "m",
				"Quantity": count.M,
			})
		}
		if count.L != 1 {
			products = append(products, map[string]interface{}{
				"Name":     name,
				"Size":     "m",
				"Quantity": count.L,
			})
		}
	}
	out["Products"] = products
	return out
}
