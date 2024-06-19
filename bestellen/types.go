package main

import "go.mongodb.org/mongo-driver/bson/primitive"

const (
	StatusCreated = iota
	StatusKitchen
	StatusDone
	StatusDelivery
	StatusDelivered
)

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
