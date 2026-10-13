package apiservice

import "context"

func (*Service) Hi(ctx context.Context) (*Hi, error) {
	resp := &Hi{
		Hi: "hi",
	}
	return resp, nil
}
