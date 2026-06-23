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

	// Provide the request field definitions here.
	#fields: [string]: #field

	// Provide the maximum page size returned in responses here.
	// If not set, the page size and token fields are not generated.
	#maxPageSize: int

	// If true, adds an order_by query parameter per AIP-132.
	#orderable: bool | *false

	// The name of the resource, used to generate the operations.
	#singular: _#resource_parts[len(_#resource_parts)-1]
	#plural:   string | *"\(#singular)s"

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
			for f in [{
				name:        "order_by"
				description: "Comma-separated list of fields to order by. See [AIP-132](https://google.aip.dev/132#ordering)."
				required:    false
				in:          "query"
				schema: type: "string"
			}] if #orderable {
				f
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
							required: [
								// https://google.aip.dev/132 the response message *must* include one repeated field corresponding to the resources being returned.
								(_arrayFieldName),
								// The next_page_token field, which supports pagination, *must* be included on all list response messages.
								if #maxPageSize != _|_ {"next_page_token"},
							]
						}
					}
				}
			}
			default: {
				description: "Error"
				content: {
					"application/json": {
						schema: $ref: "#/components/schemas/Error"
					}
				}
			}
		}
	}
}

// #CustomGet defines a safe custom method using HTTP GET.
// GET must be used for methods that only retrieve data.
// See [AIP-136](https://google.aip.dev/136).
#CustomGet: openapi.#path & {
	#resource!: string
	#verb!:     string
	#fields: [string]: #field
	#responseSchema: _ | *{$ref: #resource}

	#singular:        _#resource_parts[len(_#resource_parts)-1]
	_#resource_parts: strings.Split(#resource, "/")

	_#params: list.Concat([[for k, v in #fields {
		name: k
		if v.description != _|_ {
			description: v.description
		}
		in:       "path"
		required: true
		schema: type: "string"
	}]])

	get: {
		summary:     "\(strings.ToTitle(#verb)) \(#singular)"
		operationId: "\(strings.ToTitle(#verb))\(#singular)"
		description: "\(operationId) is a custom method on \(#singular) and complies with [AIP-136](https://google.aip.dev/136)."
		parameters:  _#params
		responses: {
			"200": {
				description: "Success"
				content: "application/json": schema: #responseSchema
			}
			default: {
				description: "Error"
				content: "application/json": schema: $ref: "#/components/schemas/Error"
			}
		}
	}
}

// #CustomPost defines a mutating custom method using HTTP POST.
// POST must be used if the method has side effects or mutates resources or data.
// See [AIP-136](https://google.aip.dev/136).
#CustomPost: openapi.#path & {
	#resource!: string
	#verb!:     string
	#fields: [string]: #field
	#responseSchema: _ | *{$ref: #resource}
	#requestSchema!: openapi.#schema | openapi.#reference

	#singular:        _#resource_parts[len(_#resource_parts)-1]
	_#resource_parts: strings.Split(#resource, "/")

	_#params: list.Concat([[for k, v in #fields {
		name: k
		if v.description != _|_ {
			description: v.description
		}
		in:       "path"
		required: true
		schema: type: "string"
	}]])

	post: {
		summary:     "\(strings.ToTitle(#verb)) \(#singular)"
		operationId: "\(strings.ToTitle(#verb))\(#singular)"
		description: "\(operationId) is a custom method on \(#singular) and complies with [AIP-136](https://google.aip.dev/136)."
		parameters:  _#params
		requestBody: {
			required: true
			content: "application/json": schema: #requestSchema
		}
		responses: {
			"200": {
				description: "Success"
				content: "application/json": schema: #responseSchema
			}
			default: {
				description: "Error"
				content: "application/json": schema: $ref: "#/components/schemas/Error"
			}
		}
	}
}
#Get: openapi.#path & {
	// Provide the $ref of the resource here.
	#resource!: string

	// Provide the request field definitions here.
	#fields: [string]: #field

	// The name of the resource, used to generate the operations.
	#singular: _#resource_parts[len(_#resource_parts)-1]

	_#resource_parts: strings.Split(#resource, "/")

	get: {
		summary:     "Get a \(#singular)"
		operationId: "Get\(#singular)"
		description: "\(operationId) gets a single \(#singular) and complies with the [AIP-131](https://google.aip.dev/131) Standard Get."

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
			// A resource name field must be included.  It should be called "name".
			{
				name:        "name"
				description: "The resource name of the \(#singular) to Get."
				in:          "path"
				required:    true
				schema: type: "string"
			},
		]])

		responses: {
			"200": {
				description: "Success"
				content: {
					"application/json": {
						schema: $ref: #resource
					}
				}
			}
			default: {
				description: "Error"
				content: {
					"application/json": {
						schema: $ref: "#/components/schemas/Error"
					}
				}
			}
		}
	}
}

#Create: openapi.#path & {
	// Provide the $ref of the resource here.
	#resource!: string

	// Provide the request field definitions here. ID fields must be in the
	// path. The entirety of the body must be the #resource, defined automatically.  All other fields
	// should be in the params.
	#fields: [string]: #field

	// The name of the resource, used to generate the operations.
	#singular: _#resource_parts[len(_#resource_parts)-1]

	_#resource_parts: strings.Split(#resource, "/")

	post: {
		summary:     "Create a \(#singular)"
		operationId: "Create\(#singular)"
		description: "\(operationId) creates a new \(#singular) and complies with the [AIP-133](https://google.aip.dev/133) Standard Create."

		requestBody: {
			required:    true
			description: "A \(#singular) to be created"
			content: {
				"application/json": {
					schema: $ref: #resource
				}
			}
		}

		parameters: [for k, v in #fields {
			name: k
			if v.description != _|_ {
				description: v.description
			}
			if v.behavior == "identifier" {
				in:       "path"
				required: true
				schema: type: "string"
			}
			if v.behavior != "identifier" {
				in:     "query"
				schema: type: v.type
			}
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
			default: {
				description: "Error"
				content: {
					"application/json": {
						schema: $ref: "#/components/schemas/Error"
					}
				}
			}
		}
	}
}

// #Update is a path-level wrapper around #UpdateOp that exposes the AIP-134
// Standard Update under `patch:`. Use this when unifying with other path-level
// helpers like `#Get & #Update & #Delete` on the same path entry. When you
// need finer-grained scoping (e.g. to keep `#allow_missing` from leaking
// across sibling operations on the same path), apply #UpdateOp directly under
// the `patch:` key instead.
#Update: X = openapi.#path & {
	// Provide the $ref of the resource here.
	#resource!: string

	// Provide the request field definitions here. ID fields must be in the
	// path. The entirety of the body must be the #resource.
	#fields: [string]: #field

	// If set to true, enables the allow_missing field on the request payload.
	#allow_missing: bool | *false

	patch: #UpdateOp & {
		#resource:      X.#resource
		#fields:        X.#fields
		#allow_missing: X.#allow_missing
	}
}

// #UpdateOp is an operation (instead of path) level definition that complies with
// [AIP-134](https://google.aip.dev/134) Standard Update. Apply it under the
// `patch:` key of a path entry so its inputs (#resource, #allow_missing, etc.)
// are scoped to the operation and do not leak across sibling operations on
// the same path.
#UpdateOp: openapi.#operation & {
	// Provide the $ref of the resource here.
	#resource!: string

	// Provide the request field definitions here. ID fields must be in the
	// path. The entirety of the body must be the #resource.
	#fields: [string]: #field

	// If set to true, enables the allow_missing field on the request payload.
	#allow_missing: bool | *false

	// The name of the resource, used to generate the operations.
	#singular: _#resource_parts[len(_#resource_parts)-1]

	_#resource_parts: strings.Split(#resource, "/")

	_fieldName: strings.ToCamel(#singular)

	// Precompute request body properties as the conditionals won't unify against
	// cba.#ApiBaseline's requestBody because disjunction arms are evaluated
	// before conditional fields are resolved.
	_extraBodyProps: {
		if #allow_missing {
			allow_missing: {
				type:        "boolean"
				description: "If set to true, and the \(#singular) is not found, a new \(#singular) will be created." // In this situation, `update_mask` is ignored.
			}
		}
	}

	summary:     "Update a \(#singular)"
	operationId: "Update\(#singular)"
	description: "\(operationId) updates an existing \(#singular) and complies with the [AIP-134](https://google.aip.dev/134) Standard Update."

	requestBody: {
		required: true
		content: {
			"application/json": {
				schema: {
					type:        "object"
					description: "\(_fieldName) is the \(#singular) to update."
					properties: {
						(_fieldName): $ref: #resource
					} & _extraBodyProps
					required: [
						(_fieldName),
					]
				}
			}
		}
	}

	parameters: list.Concat([[for k, v in #fields {
		name: k
		if v.description != _|_ {
			description: v.description
		}

		// identifying fields must be in the path.
		if v.behavior == "identifier" {
			in:       "path"
			required: true
			schema: type: "string"
		}
	},
	], [
		// A resource name field must be included.  It should be called "name".
		{
			name:        "name"
			description: "The resource name of the \(#singular) to Update."
			in:          "path"
			required:    true
			schema: type: "string"
		},
	]])

	responses: {
		"200": {
			description: "Success"
			content: {
				"application/json": {
					schema: $ref: #resource
				}
			}
		}
		default: {
			description: "Error"
			content: {
				"application/json": {
					schema: $ref: "#/components/schemas/Error"
				}
			}
		}
	}
}

#Delete: openapi.#path & {
	// Provide the $ref of the resource here
	#resource!: string

	// Provide the request field definitions here. Identifier fields will be
	// placed in the path.
	#fields: [string]: #field

	// The name of the resource, used to generate the operations.
	#singular: _#resource_parts[len(_#resource_parts)-1]

	_#resource_parts: strings.Split(#resource, "/")

	delete: {
		summary:     "Delete a \(#singular)"
		operationId: "Delete\(#singular)"
		description: "\(operationId) deletes an existing \(#singular) and complies with the [AIP-135](https://google.aip.dev/135) Standard Delete."

		parameters: list.Concat([[for k, v in #fields {
			name: k
			if v.description != _|_ {
				description: v.description
			}
			in:       "path"
			required: true
			schema: type: "string"
		}], [
			{
				name:        "name"
				description: "The resource name of the \(#singular) to delete."
				in:          "path"
				required:    true
				schema: type: "string"
			},
		]])

		responses: {
			"200": {
				description: "Success"
				// TODO: If the resource is soft-deleted, the response should be the resource itself.
			}
			default: {
				description: "Error"
				content: {
					"application/json": {
						schema: $ref: "#/components/schemas/Error"
					}
				}
			}
		}
	}
}

#BatchUpdate: openapi.#path & {
	// Provide the $ref of the resource here
	#resource!: string

	// If set to true, enables the allow_missing field on the request payload.
	#allow_missing: bool | *false

	// The name of the resource, used to generate the operations.
	#singular: _#resource_parts[len(_#resource_parts)-1]
	#plural:   string | *"\(#singular)s"

	_#resource_parts: strings.Split(#resource, "/")

	_fieldName:      strings.ToCamel(#singular)
	_arrayFieldName: strings.ToCamel(#plural)

	// Precompute conditional properties for the same reason as #UpdateOp:
	// inlining them inside the schema fails to unify against
	// cba.#ApiBaseline's requestBody disjunction.
	//
	// allow_missing originates on the per-item UpdateRequest (AIP-134).
	// AIP-234 permits "hoisting" such fields to the batch level, where setting
	// them applies to every item in the batch and any per-item value must match
	// the batch-level value. See https://google.aip.dev/234#request-message.
	// We emit it in both places when #allow_missing is true.
	_extraItemProps: {
		if #allow_missing {
			allow_missing: {
				type:        "boolean"
				description: "If set to true, and the \(#singular) is not found, a new \(#singular) will be created."
			}
		}
	}
	_extraBatchProps: {
		if #allow_missing {
			allow_missing: {
				type:        "boolean"
				description: "If set to true, and any \(#singular) in `requests` is not found, a new \(#singular) will be created. Per [AIP-234](https://google.aip.dev/234#request-message), if both this field and the per-request `allow_missing` are set, they must match."
			}
		}
	}

	post: {
		summary:     "Update several \(#plural)"
		operationId: "BatchUpdate\(#plural)"
		description: "\(operationId) modifies a set of \(#plural) in a single transaction, and complies with the [AIP-234](https://google.aip.dev/234) Batch Update."

		requestBody: {
			required:    true
			description: "A list of \(#plural) specifying the resources to update."
			content: {
				"application/json": {
					schema: {
						type:        "object"
						description: "A sequence of request messages specifying the \(#plural) to update.  A maximum of 1000 \(#plural) can be modified in a batch."
						properties: {
							requests: {
								type: "array"
								items: {
									type:        "object"
									description: "\(_fieldName) is a \(#singular) to update."
									properties: {
										(_fieldName): $ref: #resource
									} & _extraItemProps
									required: [
										(_fieldName),
									]
								}
							}
						} & _extraBatchProps
						required: [
							"requests",
						]
					}
				}
			}
		}

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
							}
							required: [
								// https://google.aip.dev/234 the response message *must* include one repeated field corresponding to the resources being returned.
								(_arrayFieldName),
							]
						}
					}
				}
			}
			default: {
				description: "Error"
				content: {
					"application/json": {
						schema: $ref: "#/components/schemas/Error"
					}
				}
			}
		}
	}
}
