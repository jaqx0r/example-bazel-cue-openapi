package apiservice

// ensure we've conformed to the generated interface with a compile-time check
var _ StrictServerInterface = (*ApiService)(nil)

type ApiService struct{}

func New() ApiService {
	return ApiService{}
}
