workspace(name = "io_bazel_rules_hocon")

load("@bazel_tools//tools/build_defs/repo:http.bzl", "http_archive")

bazel_skylib_tag = "1.0.2"

bazel_skylib_sha256 = "97e70364e9249702246c0e9444bccdc4b847bed1eb03c5a3ece4f83dfe6abc44"

http_archive(
    name = "bazel_skylib",
    sha256 = bazel_skylib_sha256,
    urls = [
        "https://mirror.bazel.build/github.com/bazelbuild/bazel-skylib/releases/download/{tag}/bazel-skylib-{tag}.tar.gz".format(tag = bazel_skylib_tag),
        "https://github.com/bazelbuild/bazel-skylib/releases/download/{tag}/bazel-skylib-{tag}.tar.gz".format(tag = bazel_skylib_tag),
    ],
)

protobuf_tag = "3.10.1"

protobuf_sha256 = "678d91d8a939a1ef9cb268e1f20c14cd55e40361dc397bb5881e4e1e532679b1"

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

buildtools_tag = "0.29.0"

buildtools_sha256 = "05eb52437fb250c7591dd6cbcfd1f9b5b61d85d6b20f04b041e0830dd1ab39b3"

http_archive(
    name = "com_github_bazelbuild_buildtools",
    sha256 = buildtools_sha256,
    strip_prefix = "buildtools-{}".format(buildtools_tag),
    urls = ["https://github.com/bazelbuild/buildtools/archive/{}.zip".format(buildtools_tag)],
)

load("@com_github_bazelbuild_buildtools//buildifier:deps.bzl", "buildifier_dependencies")

buildifier_dependencies()

# io_bazel_rules_go

rules_go_tag = "v0.20.2"

rules_go_sha256 = "b9aa86ec08a292b97ec4591cf578e020b35f98e12173bbd4a921f84f583aebd9"

http_archive(
    name = "io_bazel_rules_go",
    sha256 = rules_go_sha256,
    urls = [
        "https://storage.googleapis.com/bazel-mirror/github.com/bazelbuild/rules_go/releases/download/{tag}/rules_go-{tag}.tar.gz".format(tag = rules_go_tag),
        "https://github.com/bazelbuild/rules_go/releases/download/{tag}/rules_go-{tag}.tar.gz".format(tag = rules_go_tag),
    ],
)

load("@io_bazel_rules_go//go:deps.bzl", "go_register_toolchains", "go_rules_dependencies")

go_rules_dependencies()

go_register_toolchains()

rules_scala_annex_version = "ae99fcb08bbddfc24fef00d7b13f6c065e1df8d5"

rules_scala_annex_sha256 = "1630fc7ecc7a4ffeabcdef73c7600eab9cf3fd2377db1f69b8ce1927560211ff"

http_archive(
    name = "rules_scala_annex",
    sha256 = rules_scala_annex_sha256,
    strip_prefix = "rules_scala-{}".format(rules_scala_annex_version),
    type = "zip",
    url = "https://github.com/higherkindness/rules_scala/archive/{}.zip".format(rules_scala_annex_version),
)

rules_jvm_external_tag = "2.9"

rules_jvm_external_sha256 = "e5b97a31a3e8feed91636f42e19b11c49487b85e5de2f387c999ea14d77c7f45"

http_archive(
    name = "rules_jvm_external",
    sha256 = rules_jvm_external_sha256,
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

load("//:workspace.bzl", "hocon_repositories")

hocon_repositories()

load("@hocon_maven//:defs.bzl", hocon_maven_install = "pinned_maven_install")

hocon_maven_install()

bind(
    name = "default_scala",
    actual = "//scala:2_11",
)

# Necessary to use JDK 8 (which is needed by Scala 2.11)
jdk_build_file_content = """
filegroup(
    name = "jdk",
    srcs = glob(["**/*"]),
    visibility = ["//visibility:public"],
)
filegroup(
    name = "java",
    srcs = ["bin/java"],
    visibility = ["//visibility:public"],
)
"""

http_archive(
    name = "jdk8-linux",
    build_file_content = jdk_build_file_content,
    sha256 = "dd28d6d2cde2b931caf94ac2422a2ad082ea62f0beee3bf7057317c53093de93",
    strip_prefix = "jdk8u212-b03",
    url = "https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u212-b03/OpenJDK8U-jdk_x64_linux_hotspot_8u212b03.tar.gz",
)

http_archive(
    name = "jdk8-osx",
    build_file_content = jdk_build_file_content,
    sha256 = "3d80857e1bb44bf4abe6d70ba3bb2aae412794d335abe46b26eb904ab6226fe0",
    strip_prefix = "jdk8u212-b03/Contents/Home",
    url = "https://github.com/AdoptOpenJDK/openjdk8-binaries/releases/download/jdk8u212-b03/OpenJDK8U-jdk_x64_mac_hotspot_8u212b03.tar.gz",
)
