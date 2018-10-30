workspace(name = "com_lucidchart_rules_hocon")

skylib_version = "8cecf885c8bf4c51e82fd6b50b9dd68d2c98f757"
http_archive(
    name = "bazel_skylib",
    sha256 = "d54e5372d784ceb365f7d38c3dad7773f73b3b8ebc8fb90d58435a92b6a20256",
    strip_prefix = "bazel-skylib-{}".format(skylib_version),
    type = "zip",
    url = "https://github.com/bazelbuild/bazel-skylib/archive/{}.zip".format(skylib_version),
)

protobuf_version = "0038ff49af882463c2af9049356eed7df45c3e8e"
http_archive(
    name = "com_google_protobuf",
    sha256 = "2c8f8614fb1be709d68abaab6b4791682aa7db2048012dd4642d3a50b4f67cb3",
    strip_prefix = "protobuf-{}".format(protobuf_version),
    type = "zip",
    url = "https://github.com/lucidsoftware/protobuf/archive/{}.zip".format(protobuf_version),
)

rules_scala_annex_version = "7d053fc1be463e79c5e9e35d2123b1759cfd16e8"
http_archive(
    name = "rules_scala_annex",
    sha256 = "ad0a269ba6965d2321a81331ac065d4603e62576c9d3c6f65b8c9c3a709b8536",
    strip_prefix = "rules_scala_annex-{}".format(rules_scala_annex_version),
    type = "zip",
    url = "https://github.com/andyscott/rules_scala_annex/archive/{}.zip".format(rules_scala_annex_version),
)

load(
    "@rules_scala_annex//rules/scala:workspace.bzl",
    "scala_register_toolchains",
    "scala_repositories",
    "scala_repository"
)
scala_repositories()
scala_register_toolchains()
scala_repository(
    "scala",
    ("org.scala-lang", "2.11.12"),
    "@compiler_bridge_2_11//:src",
)

load(
    "@rules_scala_annex//rules/scalafmt:workspace.bzl",
    "scalafmt_repositories",
    "scalafmt_default_config"
)
scalafmt_repositories()
scalafmt_default_config()

load("//:workspace.bzl", "hocon_repositories")
hocon_repositories()
