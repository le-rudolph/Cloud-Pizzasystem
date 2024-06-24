package main

import (
	"embed"
	"fmt"
	"html/template"
	"log"
	"math"
	"net/http"
	"time"
)

//go:embed templates/*
var templates embed.FS

//go:embed static/*
var static embed.FS

func main() {
	conf := ConfigFromEnvironment()
	fmt.Println("Current configuration:", conf)

	base := template.New("")
	base.Funcs(template.FuncMap{
		"ToEuro": func(ct int) string {
			return fmt.Sprintf("%.2f", float32(ct)/100.0)
		},
	})
	temp, err := base.ParseFS(templates, "templates/*")
	if err != nil {
		panic(err)
	}

	var s *Server
	for i := 1; i <= 5; i++ {
		s, err = NewServer(conf, temp, static)
		if err != nil {
			log.Printf("Error creating server: %+v", err)
		} else {
			break
		}
		time.Sleep(time.Duration(math.Pow(2, float64(i))) * time.Second)
	}
	if s == nil {
		log.Fatal("Cannot create server.")
	}
	s.RunEventHandlers()
	fmt.Println("Listening on http://" + conf.ServerAddress)
	err = http.ListenAndServe(conf.ServerAddress, s)
	s.StopEventHandlers()
	if err != nil {
		panic(err)
	}
}
