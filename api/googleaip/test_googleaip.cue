package googleaip_test

import (
	"github.com/jaqx0r/example-bazel-cue-openapi/api/googleaip"
)

"/tests/{test_id}": googleaip.#Get & {
	#resource: "#/components/schemas/Test"

	#fields: {
		test_id: {
			type:     string
			behavior: "required"
		}
	}
}

"/testList": googleaip.#List & {
	#resource: "#/components/schemas/Test"
}

"/testListWithMaxPageSize": googleaip.#List & {
	#resource:    "#/components/schemas/Test"
	#maxPageSize: 100
}
