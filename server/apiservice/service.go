package apiservice

import (
	_ "github.com/oapi-codegen/runtime"       // keep for generated client
	_ "github.com/oapi-codegen/runtime/types" // keep for generated client
)

// ensure we've conformed to the generated interface with a compile-time check
var _ StrictServerInterface = (*ApiService)(nil)

type ApiService struct{}

func New() ApiService {
	return ApiService{}
}
