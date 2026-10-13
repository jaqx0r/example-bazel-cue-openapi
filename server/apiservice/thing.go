package apiservice

import (
	"context"
	"crypto/sha256"
	"fmt"
	"log"

	"github.com/google/uuid"
	"github.com/jaqx0r/pagination"
)

func (*Service) ListThings(ctx context.Context, req ListThingsParams) (*ListThingsOK, error) {
	var things = []Thing{
		{
			UID:   uuid.New(),
			Title: NewOptString("thing"),
		},
	}

	paramSig := sha256.New()
	paramSig.Write([]byte(req.Filter.Or("")))
	nonce := paramSig.Sum(nil)

	offset, err := pagination.Decode[int](req.PageToken.Or(""), nonce)

	pageSize := req.PageSize.Or(0)
	if pageSize <= 0 || pageSize > 1000 {
		pageSize = 1000
	}

	log.Printf("query for offset: %d and limit %d", offset, pageSize)

	token, err := pagination.Encode(pageSize, nonce)
	if err != nil {
		return nil, err
	}

	return &ListThingsOK{
		Things:        things,
		NextPageToken: token,
	}, nil
}

func (*Service) GetThing(ctx context.Context, req GetThingParams) (*Thing, error) {
	return nil, fmt.Errorf("Unimplemented")
}
