package main

import (
	"embed"
	"fmt"
	"html/template"
	"net/http"
)

//go:embed templates/*
var templates embed.FS

//go:embed static/*
var static embed.FS

func main() {
	conf := ConfigFromEnvironment()
	_ = conf

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

	s := NewServer(conf, temp, static)
	s.RunEventHandlers()
	fmt.Println("Listening on http://" + conf.ServerAddress)
	err = http.ListenAndServe(conf.ServerAddress, s)
	s.StopEventHandlers()
	if err != nil {
		panic(err)
	}
}
