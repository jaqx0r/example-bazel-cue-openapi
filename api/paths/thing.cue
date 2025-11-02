package thing

import "github.com/jaqx0r/example-bazel-cue-openapi/api/googleaip"

"/things": googleaip.#List & {
	#resource:    "#/components/schemas/Thing"
	#maxPageSize: 1000
}

"/things/{thing_id}": googleaip.#Get & {
	#resource: "#/components/schemas/Thing"
	#fields: {
		thing_id: {
			behavior: "identifier"
			type:     "string"
		}
	}
}
