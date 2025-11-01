package hi

import "github.com/jaqx0r/example-bazel-cue-openapi/api/openapi"

Hi: openapi.#schema & {
	type: "object"

	properties: {
		hi: {
			type:        "string"
			description: "a greeting"
		}
	}

	required: [
		"hi",
	]
}
