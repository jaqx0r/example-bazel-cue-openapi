package main

import (
	"flag"
	"log"
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/jaqx0r/example-bazel-cue-openapi/server/apiservice"
)

var port = flag.String("port", "8080", "Default port to serve the API on")

func main() {
	flag.Parse()

	s := apiservice.New()

	r := gin.Default()

	apiservice.RegisterHandlers(r, apiservice.NewStrictHandler(s, []apiservice.StrictMiddlewareFunc{}))

	srv := &http.Server{
		Handler: r,
		Addr:    ":" + *port,
	}

	log.Fatal(srv.ListenAndServe())
}
