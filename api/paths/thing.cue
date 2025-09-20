package thing

import "github.com/jaqx0r/example-bazel-cue-openapi/api/openapi"

"/things": openapi.#path & {
  get: {
    operationId: "ListThings"
    summary: "List Things"
    description: "Retrieve a list of Things"
    parameters: [
        {
            name: "page_size"
            description: "The maximum number of things to return. The service may return fewer than this value.  If unspecified, at most 50 things will be returned. The maximum value is 1000; values above 1000 will be coerced to 1000."
            in: "query"
            schema: {
                type: "integer"
            }
        },
        {
            name: "page_token"
            description: "A page token, received from a previous `ListThings` call. Provide this to retrieve the subsequent page. When paginating, all other parameters provided to `ListThings` must match the call that provided the page token."
            in: "query"
            schema: {
                type: "string"
            }
        },
    ]
    responses: {
      '200': {
        description: "OK"
        content: {
            "application/json": {
                schema: {
                    type: "object"
                    properties: {
                        "things": {
                            type: "array"
                            items:
                                $ref: "#/components/schemas/Thing"
                        }
                    }
                }
            }
         }
       }
    }
  }
}
