package main

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
	Status   int
	Price    int
	Products map[string]Count
}
