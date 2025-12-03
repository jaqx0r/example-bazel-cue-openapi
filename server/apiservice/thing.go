package apiservice

import (
	"context"
	"crypto/sha256"
	"log"

	"github.com/google/uuid"
	"github.com/jaqx0r/pagination"
)

func (ApiService) ListThings(ctx context.Context, req ListThingsRequestObject) (ListThingsResponseObject, error) {
	var things = []Thing{
		{
			Uid:   uuid.New(),
			Title: "thing",
		},
	}

	paramSig := sha256.New()
	paramSig.Write([]byte(req.Params.Filter))
	nonce := paramSig.Sum(nil)

	offset, err := pagination.Decode(req.Params.PageToken, nonce)

	log.Printf("query for offset: %d and limit %d", offset, req.Params.PageSize)

	token, err := pagination.Encode(offset, req.Params.PageSize, nonce)
	if err != nil {
		return nil, err
	}

	return ListThings200JSONResponse{
		Things:        things,
		NextPageToken: token,
	}, nil
}

func (ApiService) GetThing(ctx context.Context, req GetThingRequestObject) (GetThingResponseObject, error) {
	return UnimplementedResponse{}, nil
}
