// Copied from https://github.com/tetsu-tech/cue-openapi-example/blob/main/definition/openapi.cue

package openapi

#openapi: {
	openapi: "3.0.3"
	info: {
		title: string
		description?: string
		termsOfService?: string
		contact?: {
			name?: string
			url?: string
			email?: string
		} 
		license?: {
			name: string
			url?: string
		}
		version: string
	}
	servers?: [...#server]
	paths: #paths
	components?: #components
	tags?: [...#tag]
	externalDocs?: #external_docs
}

#server: {
	url: string
	description?: string
	variables?: [string]: {
		enum?: [...string]
		default: string
		description?: string
	}
}

#components: {
	schemas?: [string]: #schema | #reference
	responses?: [string]: #response | #reference
	parameters?: [string]: #parameter | #reference
	examples?: [string]: #example | #reference
	requestBodies?: [string]: #request_body | #reference
	headers?: [string]: #header | #reference
	links?: [string]: #link | #reference
	callbacks?: [string]: #callback | #reference
}

#paths: [string]: #path

#path: {
	$ref?: string
	summary?: string
	description?: string
	get?: #operation
	put?: #operation
	post?: #operation
	delete?: #operation
	options?: #operation
	head?: #operation
	patch?: #operation
	trace?: #operation
	servers?: [...#server]
}

#operation: {
	tags?: [string, ...]
	summary?: string
	description?: string
	externalDocs?: #external_docs
	operationId?: string
	parameters?: [...#parameter | #reference]
	requestBody?: #request_body | #reference
	responses: [string]: #response
	callbacks?: [string]: #callback | #reference
	deprecated?: bool
	servers?: [...#server]
}

#external_docs: {
	description?: string
	url: string
}

#parameter: {
	name: string
	in: "query" | "header" | "path" | "cookie"
	description?: string
	required?: bool
	deprecated?: bool
	allowEmptyValue?: bool
	style?: string
	explode?: bool
	allowReserved?: bool
	schema?: #schema | #reference
	example?: _
	examples?: [string]: #example | #reference
}

#request_body: {
	description?: string
	content: [string]: #media_type
	required?: bool
}

#media_type: {
	schema?: #schema | #reference
	example?: _
	examples?: [string]: #example | #reference
	encoding?: [string]: #encoding
}

#encoding: {
	contentType?: string
	headers?: [string]: #header | #reference
	style?: string
	explode?: bool
	allowReserved?: bool
}

#response: {
	description: string
	headers?: [string]: #header | #reference
	content?: [string]: #media_type
	links?: [string]: #link | #reference
}

#callback: {
	[string]: #path
}

#example: {
	summary?: string
	description?: string
	value?: _
	externalValue?: string
}

#link: {
	operationRef?: string
	operationId?: string
	parameters: [string]: _
	requestBody: _
	description: string
	server: #server
}

#header: {
	description?: string
	required?: bool
	deprecated?: bool
	allowEmptyValue?: bool
	style?: string
	explode?: bool
	allowReserved?: bool
	schema?: #schema | #reference
	example?: _
	examples?: [string]: #example | #reference
}

#tag: {
	name: string
	description?: string
	externalDocs?: #external_docs
}

#reference: $ref: string

#schema: {
	type: "object" | "array" | "null" | "number" | "string" | "boolean" | "integer"
	title?: string
	description?: string
	items?: #schema | #reference
	properties?: [string]: #schema
	format?: "int32" | "int64" | "float" | "double" | "byte" | "binary"  | "date" | "date-time" | "password" | "uuid"
	example?: _
	nullable?: bool
	required?: [...string]
	nullable?: bool
	readOnly?: bool
	writeOnly?: bool
	externalDocs?: #external_docs
	example?: _
	deprecated?: bool
	default?: _
}
