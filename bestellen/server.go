package main

import (
	"context"
	"fmt"
	"go.mongodb.org/mongo-driver/bson"
	"go.mongodb.org/mongo-driver/bson/primitive"
	"go.mongodb.org/mongo-driver/mongo"
	"go.mongodb.org/mongo-driver/mongo/options"
	"html/template"
	"io/fs"
	"net/http"
	"strconv"
	"strings"
)

const (
	OrdersCollection = "Orders"
)

type server struct {
	mux       http.ServeMux
	templates *template.Template

	db *mongo.Database
}

func (s *server) ServeHTTP(writer http.ResponseWriter, request *http.Request) {
	s.mux.ServeHTTP(writer, request)
}

func (s *server) getProducts() map[string]Price {
	return map[string]Price{
		"Pizza":  {S: 1000, M: 1200, L: 1550},
		"Pommes": {S: 500, M: 800},
	}
}

func (s *server) Index(w http.ResponseWriter, r *http.Request) {
	if r.Method == "GET" {
		if err := s.templates.ExecuteTemplate(w, "index.gohtml", s.getProducts()); err != nil {
			panic(err)
		}
	} else {
		r.ParseForm()

		products := s.getProducts()
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

		result, err := s.db.Collection(OrdersCollection).InsertOne(r.Context(), order)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		http.Redirect(w, r, fmt.Sprintf("/status/%s", result.InsertedID.(primitive.ObjectID).Hex()), http.StatusFound)
	}
}

func (s *server) Status(w http.ResponseWriter, r *http.Request) {
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

func NewServer(conf *Config, tmpl *template.Template, static fs.FS) http.Handler {
	db, err := mongo.Connect(context.Background(), options.Client().ApplyURI(conf.DatabaseUri))
	if err != nil {
		panic(err)
	}

	s := server{http.ServeMux{}, tmpl, db.Database(conf.DatabaseDb)}
	s.mux.Handle("/static/", http.FileServer(http.FS(static)))
	s.mux.HandleFunc("/{$}", s.Index)
	s.mux.HandleFunc("/status/{status}", s.Status)
	return &s
}
