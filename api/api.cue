import (
  "github.com/jaqx0r/example-bazel-cue-openapi/api/openapi"
  s  "github.com/jaqx0r/example-bazel-cue-openapi/api/schemas"
)

openapi.#openapi & {
  info: {
    title: "Example API"
    version: "v1.0"
  }
  components: schemas: s
}
