package apiservice

import "context"

func (ApiService) Hi(ctx context.Context, req HiRequestObject) (HiResponseObject, error) {
	resp := Hi{
		Hi: "hi",
	}
	return Hi200JSONResponse(resp), nil
}
