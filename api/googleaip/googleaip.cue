// Package googleaip contains definitions for automating the creation of OpenAPI paths that follow the https://google.aip.dev specification.
package googleaip

import (
	"list"
	"strings"

	"github.com/jaqx0r/example-bazel-cue-openapi/api/openapi"
)

#field: {
	// type is the data type that this field accepts.
	type: string

	description?: string

	// behavior describes aspects of the field's behaviour per [AIP-203](https://google.aip.dev/203).
	// identifier: The field is used to identify the resource -- it is attached to name or id fields.
	// immutable: The field cannot be changed after creation.
	// input_only: The field is provided in requests, but the corresponding field will never be included in the response.
	// optional: The field may be omitted.
	// output_only: The field is provided in responses but any request containing this field will have no effect.
	// required: The field must always be specified to a non-empty value.
	// unordered_list: The field does not guarantee order of items in a list.
	behavior: "identifier" | "immutable" | "input_only" | *"optional" | "output_only" | "required" | "unordered_list"
}

#List: openapi.#path & {
	// Provide the $ref of the resource here.
	#resource!: string

	// Provide the field definitions here.
	#fields: [string]: #field

	// Provide the maximum page size returned in responses here.
	// If not set, the page size and token fields are not generated.
	#maxPageSize: int

	// The name of the resource, used to generate the operations.
	#singular: _#resource_parts[len(_#resource_parts)-1]
	#plural:   "\(#singular)s"

	_#resource_parts: strings.Split(#resource, "/")

	get: {
		summary:     "List \(#plural)"
		operationId: "List\(#plural)"
		description: "\(operationId) lists \(#plural) and complies with the [AIP-132](https://google.aip.dev/132) Standard List."

		parameters: list.Concat([[for k, v in #fields {
			name: k
			if v.description != _|_ {
				description: v.description
			}

			// AIP-131 does not allow any other fields, so these must be required IDs and must be in the path.
			in:       "path"
			required: true
			schema: type: "string"
		},
		], [
			{
				name:        "filter"
				description: "filter is an expression that conforms to [AIP-160](https://google.aip.dev/160)"
				required:    false
				in:          "query"
				schema: type: "string"
			},
		],
			[for f in [
				{
					name:        "page_size"
					description: "The maximum number of resources to return.  The service may return fewer than this value.  If unspecified, at most \(#maxPageSize) will be returned.  The maximum value is \(#maxPageSize); values above \(#maxPageSize) will be coerced to \(#maxPageSize)."
					required:    false
					in:          "query"
					schema: type: "integer"
				},
				{
					name:        "page_token"
					description: "A page token, received from a previous `\(operationId)` call.  Provide this to retrieve the subsequent page.  When paginating, all other parameters provided to `\(operationId)` must match the call that provided the page token."
					required:    false
					in:          "query"
					schema: type: "string"
				},
			] if #maxPageSize != _|_ {
				f
			},
			]])

		_arrayFieldName: strings.ToCamel(#plural)

		responses: {
			"200": {
				description: "Success"
				content: {
					"application/json": {
						schema: {
							type: "object"
							properties: {
								(_arrayFieldName): {
									type: "array"
									items: $ref: #resource
								}
								if #maxPageSize != _|_ {
									next_page_token: {
										type:        "string"
										description: "A token, which can be sent as `page_token` to retrieve the next page. If this field is omitted, there are no subsequent pages."
									}
								}
							}
						}
					}
				}
			}
			"401": $ref: "#/components/responses/Unauthorized"
			"404": $ref: "#/components/responses/NotFound"
			"501": $ref: "#/components/responses/Unimplemented"
		}
	}
}

#Get: openapi.#path & {
	// Provide the $ref of the resource here.
	#resource!: string

	// Provide the field definitions here.
	#fields: [string]: #field

	// The name of the resource, used to generate the operations.
	#singular: _#resource_parts[len(_#resource_parts)-1]

	_#resource_parts: strings.Split(#resource, "/")

	get: {
		summary:     "Get a \(#singular)"
		operationId: "Get\(#singular)"
		description: "\(operationId) gets a single \(#singular) and complies with the [AIP-131](https://google.aip.dev/131) Standard Get."

		parameters: [for k, v in #fields {
			name: k
			if v.description != _|_ {
				description: v.description
			}

			// AIP-131 does not allow any other fields, so these must be required IDs and must be in the path.
			in:       "path"
			required: true
			schema: type: "string"
		},
		]

		responses: {
			"200": {
				description: "Success"
				content: {
					"application/json": {
						schema: $ref: #resource
					}
				}
			}
			"401": $ref: "#/components/responses/Unauthorized"
			"404": $ref: "#/components/responses/NotFound"
			"501": $ref: "#/components/responses/Unimplemented"
		}
	}
}
