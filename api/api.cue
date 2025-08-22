import (
  "github.com/jaqx0r/example-bazel-cue-openapi/api/openapi"
  s "github.com/jaqx0r/example-bazel-cue-openapi/api/schemas"
  p "github.com/jaqx0r/example-bazel-cue-openapi/api/paths"
)

openapi.#openapi & {
  info: {
    title: "Example API"
    version: "v1.0"
    description: """
     An example API to demonstrate bazel integration with code generators.
    """
  }
  paths: p
  components: schemas: s
}
