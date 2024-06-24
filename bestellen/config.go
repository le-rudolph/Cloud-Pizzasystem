package main

import (
	"os"
)

type Config struct {
	QueueUri    string
	DatabaseUri string
	DatabaseDb  string

	ServerAddress string

	QueueOutgoing string
	QueueUpdates  string

	ProductsUrl string
}

func defaultConfig() *Config {
	return &Config{
		"amqp://guest:guest@localhost:5672",
		"mongodb://root:example@localhost",
		"Pizza",
		"0.0.0.0:14621",

		"order",
		"delivery",
		"http://localhost:3000",
	}
}

func ConfigFromEnvironment() *Config {
	conf := defaultConfig()
	if uri, ok := os.LookupEnv("QUEUE_URI"); ok {
		conf.QueueUri = uri
	}
	if uri, ok := os.LookupEnv("DATABASE_URI"); ok {
		conf.DatabaseUri = uri
	}
	if db, ok := os.LookupEnv("DATABASE_DB"); ok {
		conf.DatabaseDb = db
	}
	if addr, ok := os.LookupEnv("SERVER_ADDRESS"); ok {
		conf.ServerAddress = addr
	}
	if addr, ok := os.LookupEnv("SERVER_ADDRESS"); ok {
		conf.ServerAddress = addr
	}
	if url, ok := os.LookupEnv("PRODUCTS_URL"); ok {
		conf.ProductsUrl = url
	}
	return conf
}
