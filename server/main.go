package main

import (
	"flag"
	"log"
	"net/http"

	"github.com/jaqx0r/example-bazel-cue-openapi/server/apiservice"
)

var port = flag.String("port", "8080", "Default port to serve the API on")

func main() {
	flag.Parse()

	svc := apiservice.New()
	srv, err := apiservice.NewServer(svc)
	if err != nil {
		log.Fatalf("NewServer(%v): %v", svc, err)
	}

	if err := http.ListenAndServe(":"+*port, srv); err != nil {
		log.Fatalf("ListenAndServe(): %v", err)
	}
}
