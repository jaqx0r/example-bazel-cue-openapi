package thing

import "github.com/jaqx0r/example-bazel-cue-openapi/api/googleaip"

"/things": googleaip.#List & {
	#resource:    "#/components/schemas/Thing"
	#maxPageSize: 1000
}

"/things/{name}": googleaip.#Get & {
	#resource: "#/components/schemas/Thing"
}
