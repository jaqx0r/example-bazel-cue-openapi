package main

import (
	"flag"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
)

var port = flag.String("port", "8080", "Default port to serve the API on")

func main() {
	flag.Parse()

	r := gin.Default()

	srv := &http.Server{
		Handler: r,
		Addr:    ":" + *port,
	}

	log.Fatal(srv.ListenAndServe())
}
