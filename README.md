# An example repo using Bazel and CUE to build an OpenAPI server in Go.

You will need [`bazel`](https://bazel.build) installed, preferably with `bazelisk`.

`bazel run //server` will build and launch the server on
http://localhost:8080/hi

[api](/api) contains the CUE specification for the API.  It is exported from
CUE into an OpenAPI YAML specification by the build.  This is done with [`rules_cue`](https://github.com/seh/rules_cue).

The YAML specification is then transformed by
[`oapi-codegen`](http://github.com/oapi-codegen/oapi-codegen) into a service
handler in Go.  This is done with [`rules_oapi_codegen`](https://github.com/jaqx0r/rules_oapi_codegen).

The service is implemented in [server/apiservice](/server/apiservice), with one
file per resource.  The generated code is not in the source tree, as usual with
Bazel and as is familiar with all right-thinking software engineers.  But you
can read it in your local workspace under
`bazel-bin/server/apiservice/apiservice.go`.

Future work:
- Implement a full [resource-oriented](https://google.aip.dev/121) API example.
- Implement an [aip.dev](http://google.aip.dev) compatible generator the CUE schema.
- Implement an aip.dev validator for the generated YAML.
