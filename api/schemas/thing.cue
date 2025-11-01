package thing

import "github.com/jaqx0r/example-bazel-cue-openapi/api/openapi"

Thing: openapi.#schema & {
	type: "object"
	properties: {
		uid: {
			type:        "string"
			format:      "uuid"
			description: "A unique identifier for this Thing."
		}
		title: {
			type:        "string"
			description: "A readable title for this Thing."
		}
		state: {
			type: "string"
			// TODO be an enum
			description: "The current state of this Thing."
		}
		open_time: {
			type:        "string"
			format:      "date-time"
			description: "The open time of this Thing."
		}
	}
	required: [
		"uid",
	]
}
