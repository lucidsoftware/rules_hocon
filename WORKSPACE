workspace(name = "com_lucidchart_rules_hocon")

rules_scala_version = "b3195247d05ae4e38831938d984cadfe182701bb"

skylib_version = "7490380c6bbf9a5a060df78dc2222e7de6ffae5c"
http_archive(
    name = "bazel_skylib",
    strip_prefix = "bazel-skylib-{}".format(skylib_version),
    type = "zip",
    url = "https://github.com/bazelbuild/bazel-skylib/archive/{}.zip".format(skylib_version),
    sha256 = "16a2534ee255c0006db7300d234d624a22898ae055c9f52f30440bc65393d68b",
)

protobuf_version = "d5f0dac497f833d06f92d246431f4f2f42509e04"
http_archive(
    name = "com_google_protobuf",
    strip_prefix = "protobuf-{}".format(protobuf_version),
    type = "zip",
    url = "https://github.com/lucidsoftware/protobuf/archive/{}.zip".format(protobuf_version),
    sha256 = "ae92f39ec9a8f17de2c57ab72ce2dd044c966f7a44faed6ec584f4cea4a6c48c",
)

http_archive(
  name = "io_bazel_rules_scala",
  url = "https://github.com/bazelbuild/rules_scala/archive/%s.zip"%rules_scala_version,
  type = "zip",
  strip_prefix= "rules_scala-%s" % rules_scala_version,
)

rules_scala_annex_version = "68439082b92731fc1a7712684f05719a93b3b498"
http_archive(
  name = "rules_scala_annex",
  strip_prefix = "rules_scala_annex-{}".format(rules_scala_annex_version),
  type = "zip",
  url = "https://github.com/lucidsoftware/rules_scala_annex/archive/{}.zip".format(rules_scala_annex_version),
  sha256 = "15d5a04ecb4ef5a19a302e756c00173625882930a55a54b0062635e9215a46a8",
)

load("@rules_scala_annex//rules/scala:workspace.bzl", "annex_scala_repositories", "annex_scala_repository", "annex_scala_register_toolchains")
load("@rules_scala_annex//rules/scalafmt:workspace.bzl", "annex_scalafmt_repositories", "scalafmt_default_config")

annex_scala_repositories()
annex_scala_register_toolchains()
annex_scala_repository(
    "scala",
    ("org.scala-lang", "2.11.12"),
    "@compiler_bridge_2_11//:src",
)
annex_scalafmt_repositories()
scalafmt_default_config()

load("//:workspace.bzl", "hocon_repositories")
hocon_repositories()
