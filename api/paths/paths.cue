package paths

import "github.com/jaqx0r/example-bazel-cue-openapi/api/openapi"
import "github.com/jaqx0r/example-bazel-cue-openapi/api/paths:hi"
import "github.com/jaqx0r/example-bazel-cue-openapi/api/paths:thing"

openapi.#paths & hi & thing
