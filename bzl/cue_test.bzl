load("@bazel_skylib//rules:build_test.bzl", "build_test")
load("@rules_cue//cue:cue.bzl", "cue_consolidated_files")

def cue_test(name, srcs, module, deps):
    cue_consolidated_files(
        name = name + "_consolidated_files",
        testonly = True,
        srcs = srcs,
        module = module,
        deps = deps,
    )

    build_test(
        name = name,
        targets = [":" + name + "_consolidated_files"],
    )
