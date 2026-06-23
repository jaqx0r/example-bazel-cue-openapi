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

"/tests/{test_id}:archive": googleaip.#CustomGet & {
	#resource: "#/components/schemas/Test"
	#verb:     "archive"
	#fields: {
		test_id: {
			type:     string
			behavior: "required"
		}
	}
}

"/tests/{test_id}:publish": googleaip.#CustomPost & {
	#resource: "#/components/schemas/Test"
	#verb:     "publish"
	#fields: {
		test_id: {
			type:     string
			behavior: "required"
		}
	}
	#requestSchema: {
		type: "object"
		properties: {
			target: {
				type:        "string"
				description: "Target to publish to."
			}
		}
		required: ["target"]
	}
}
