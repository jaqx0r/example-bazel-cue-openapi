package apiservice

import "context"

// ensure we've conformed to the generated interface with a compile-time check
var _ Handler = (*Service)(nil)

type Service struct{}

func New() *Service {
	return &Service{}
}

func (s *Service) NewError(ctx context.Context, err error) *ErrorStatusCode {
	e := Error{
		Title:  err.Error(),
		Detail: err.Error(),
		Status: 500,
	}
	r := &ErrorStatusCode{}
	r.SetStatusCode(500)
	r.SetResponse(e)
	return r
}
