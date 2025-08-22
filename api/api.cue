import (
  "github.com/jaqx0r/example-bazel-cue-openapi/api/openapi"
)

openapi.#openapi & {
  info: {
    title: "Example API"
    version: "v1.0"
  }
}
