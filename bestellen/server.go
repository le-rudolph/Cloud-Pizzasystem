package main

import (
	"bytes"
	"context"
	"encoding/json"
	"fmt"
	"github.com/rabbitmq/amqp091-go"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"html/template"
	"io"
	"io/fs"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"
)

const (
	OrdersCollection = "Orders"
)

type Server struct {
	mux       http.ServeMux
	templates *template.Template

	db *mongo.Database
	q  *amqp091.Connection

	running             bool
	eventHandlerTimeout time.Duration

	qToDelivery   string
	qFromDelivery string

	productsUrl string
}

var _ http.Handler = (*Server)(nil)

func (s *Server) ServeHTTP(writer http.ResponseWriter, request *http.Request) {
	s.mux.ServeHTTP(writer, request)
}

func (s *Server) getProducts(ctx context.Context) map[string]Price {
	req, err := http.NewRequestWithContext(ctx, "GET", s.productsUrl, nil)
	if err != nil {
		log.Println("Error getting products:", err)
		return nil
	}
	resp, err := http.DefaultClient.Do(req)
	if err != nil {
		log.Println("Cannot do request:", resp)
		return nil
	}
	var b bytes.Buffer
	if _, err = io.Copy(&b, resp.Body); err != nil {
		log.Println("Error reading body:", err)
		return nil
	}
	var out map[string]Price
	if err = json.Unmarshal(b.Bytes(), &out); err != nil {
		log.Println("Cannot parse products response:", err)
		return nil
	}

	return out
}

func (s *Server) Index(w http.ResponseWriter, r *http.Request) {
	if r.Method == "GET" {
		if err := s.templates.ExecuteTemplate(w, "index.gohtml", s.getProducts(r.Context())); err != nil {
			panic(err)
		}
	} else {
		r.ParseForm()

		products := s.getProducts(r.Context())
		order := Order{}
		order.Products = make(map[string]Count)

		for k, v := range r.Form {
			if v[0] == "0" {
				continue
			}

			count, _ := strconv.Atoi(v[0])
			split := strings.Split(k, "_")
			meal := split[0]
			size := split[1]

			product, _ := order.Products[meal]

			price, ok := products[meal]
			if !ok {
				continue
			}
			itemPrice := 0
			switch size {
			case "S":
				itemPrice = price.S
				product.S += count
			case "M":
				itemPrice = price.M
				product.M += count
			case "L":
				itemPrice = price.L
				product.L += count
			default:
				continue
			}
			if itemPrice == 0 {
				continue
			}

			order.Price += itemPrice * count
			order.Products[meal] = product
		}

		order.ID = primitive.NewObjectID()

		result, err := s.db.Collection(OrdersCollection).InsertOne(r.Context(), order)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		http.Redirect(w, r, fmt.Sprintf("/status/%s", result.InsertedID.(primitive.ObjectID).Hex()), http.StatusFound)
	}
}

func (s *Server) RunEventHandlers() {
	s.running = true
	go func() {
		for s.running {
			err := s.MoveOrderToKitchen()
			if err != nil {
				log.Println("Error moving order to kitchen:", err)
			}
			time.Sleep(5 * time.Second)
		}
	}()

	go func() {
		for s.running {
			err := s.MoveOrderToDelivery()
			if err != nil {
				log.Println("Error moving order to delivery:", err)
			}
			time.Sleep(5 * time.Second)
		}
	}()

	go func() {
		for s.running {
			err := s.ReceiveDeliveries()
			if err != nil {
				log.Println("Error receiving deliveries:", err)
			}
			time.Sleep(5 * time.Second)
		}
	}()
}

func (s *Server) StopEventHandlers() {
	s.running = false
}

func (s *Server) Status(w http.ResponseWriter, r *http.Request) {
	id := strings.SplitN(r.RequestURI, "/", 3)[2]
	_id, _ := primitive.ObjectIDFromHex(id)
	result := s.db.Collection(OrdersCollection).FindOne(r.Context(), bson.D{
		{"_id", _id},
	})
	if err := result.Err(); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
	o := Order{}
	if err := result.Decode(&o); err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
	}
	o.Status++
	if err := s.templates.ExecuteTemplate(w, "status.gohtml", o); err != nil {
		panic(err)
	}
}

func NewServer(conf *Config, tmpl *template.Template, static fs.FS) (*Server, error) {
	db, err := mongo.Connect(context.Background(), options.Client().ApplyURI(conf.DatabaseUri))
	if err != nil {
		return nil, err
	}

	q, err := amqp091.Dial(conf.QueueUri)
	if err != nil {
		return nil, err
	}
	s := Server{
		http.ServeMux{},
		tmpl, db.Database(conf.DatabaseDb),
		q, false,
		10 * time.Second,
		conf.QueueOutgoing,
		conf.QueueUpdates,
		conf.ProductsUrl,
	}
	s.mux.Handle("/static/", http.FileServer(http.FS(static)))
	s.mux.HandleFunc("/{$}", s.Index)
	s.mux.HandleFunc("/status/{status}", s.Status)
	return &s, nil
}
