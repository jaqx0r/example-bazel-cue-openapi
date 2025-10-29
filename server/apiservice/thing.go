package apiservice

import (
	"context"

	"github.com/google/uuid"
)

func (ApiService) ListThings(ctx context.Context, req ListThingsRequestObject) (ListThingsResponseObject, error) {
	var things = []Thing{
		{
			Uid:   uuid.New(),
			Title: "thing",
		},
	}

	return ListThings200JSONResponse{Things: things}, nil
}
