workspace(name = "io_bazel_rules_hocon")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

bazel_skylib_tag = "1.0.2"

bazel_skylib_sha256 = "64ad2728ccdd2044216e4cec7815918b7bb3bb28c95b7e9d951f9d4eccb07625"

http_archive(
    name = "bazel_skylib",
    sha256 = bazel_skylib_sha256,
    strip_prefix = "bazel-skylib-{}".format(bazel_skylib_tag),
    type = "zip",
    url = "https://github.com/bazelbuild/bazel-skylib/archive/{}.zip".format(bazel_skylib_tag),
)

protobuf_tag = "3.11.4"

protobuf_sha256 = "9748c0d90e54ea09e5e75fb7fac16edce15d2028d4356f32211cfa3c0e956564"

http_archive(
    name = "com_google_protobuf",
    sha256 = protobuf_sha256,
    strip_prefix = "protobuf-{}".format(protobuf_tag),
    type = "zip",
    url = "https://github.com/protocolbuffers/protobuf/archive/v{}.zip".format(protobuf_tag),
)

load("@com_google_protobuf//:protobuf_deps.bzl", "protobuf_deps")

protobuf_deps()

# com_github_bazelbuild_buildtools

buildtools_tag = "2.2.1"

buildtools_sha256 = "15146c8e0f3cb9605339a4b0fe2b0e33ee67fec47e6b55d1b39c0de7ccede6fd"

http_archive(
    name = "com_github_bazelbuild_buildtools",
    sha256 = buildtools_sha256,
    strip_prefix = "buildtools-{}".format(buildtools_tag),
    urls = ["https://github.com/bazelbuild/buildtools/archive/{}.zip".format(buildtools_tag)],
)

load("@com_github_bazelbuild_buildtools//buildifier:deps.bzl", "buildifier_dependencies")

buildifier_dependencies()

# io_bazel_rules_go

rules_go_tag = "0.22.1"

rules_go_sha256 = "9fbaffc63aa802496b0de6ed708fce8fb4c34b27fa7fab6cfc64eeae900c19a7"

http_archive(
    name = "io_bazel_rules_go",
    sha256 = rules_go_sha256,
    strip_prefix = "rules_go-{}".format(rules_go_tag),
    urls = ["https://github.com/bazelbuild/rules_go/archive/v{}.zip".format(rules_go_tag)],
)

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains()

rules_scala_annex_version = "ff423d8bdd0e5383f8f2c048ffd7704bb51a91bf"

rules_scala_annex_sha256 = "ae53e9ed5fecadc7baf4637b88109471602be73dda4e5ff6b4bf1767932703c0"

http_archive(
    name = "rules_scala_annex",
    sha256 = rules_scala_annex_sha256,
    strip_prefix = "rules_scala-{}".format(rules_scala_annex_version),
    type = "zip",
    url = "https://github.com/higherkindness/rules_scala/archive/{}.zip".format(rules_scala_annex_version),
)

rules_jvm_external_tag = "4.2"

http_archive(
    name = "rules_jvm_external",
    sha256 = "cd1a77b7b02e8e008439ca76fd34f5b07aecb8c752961f9640dea15e9e5ba1ca",
    strip_prefix = "rules_jvm_external-{}".format(rules_jvm_external_tag),
    url = "https://github.com/bazelbuild/rules_jvm_external/archive/{}.zip".format(rules_jvm_external_tag),
)

load(
    "@rules_scala_annex//rules/scala:workspace.bzl",
    "scala_register_toolchains",
    "scala_repositories",
)

scala_repositories()

load("@annex//:defs.bzl", annex_pinned_maven_install = "pinned_maven_install")

annex_pinned_maven_install()

scala_register_toolchains()

load(
    "@rules_scala_annex//rules/scalafmt:workspace.bzl",
    "scalafmt_default_config",
    "scalafmt_repositories",
)

scalafmt_repositories()

load("@annex_scalafmt//:defs.bzl", annex_scalafmt_pinned_maven_install = "pinned_maven_install")

annex_scalafmt_pinned_maven_install()

scalafmt_default_config()

bind(
    name = "default_scala",
    actual = "@rules_scala_annex//src/main/scala:zinc_2_12_10",
)

load("//:workspace.bzl", "hocon_repositories")

hocon_repositories()

load("@hocon_maven//:defs.bzl", hocon_maven_install = "pinned_maven_install")

hocon_maven_install()
