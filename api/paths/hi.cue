package hi

import "github.com/jaqx0r/example-bazel-cue-openapi/api/openapi"

"/hi": openapi.#path & {
	get: {
		operationId: "hi"
		responses: {
			'200': {
				description: "success"
				content: {
					"application/json": {
						schema: {
							$ref: "#/components/schemas/Hi"
						}
					}

				}
			}
		}
	}
}
