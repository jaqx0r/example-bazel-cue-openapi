package apiservice

import (
	"context"

	"github.com/google/uuid"
)

func (ApiService) ListThings(ctx context.Context, req ListThingsRequestObject) (ListThingsResponseObject, error) {
	thingName := "thing"
	var things = []Thing{
		{
			Uid:   uuid.New(),
			Title: &thingName,
		},
	}

	return ListThings200JSONResponse{Things: &things}, nil
}
