load("@bazel_tools//tools/build_defs/repo:jvm.bzl", "jvm_maven_import_external")
load("@rules_jvm_external//:defs.bzl", "maven_install")

def hocon_repositories():
    jvm_maven_import_external(
        name = "hocon_com_typesafe_config",
        artifact = "com.typesafe:config:1.3.3",
        artifact_sha256 = "b5f1d6071f1548d05be82f59f9039c7d37a1787bd8e3c677e31ee275af4a4621",
        server_urls = ["https://repo.maven.apache.org/maven2"],
    )

    jvm_maven_import_external(
        name = "hocon_org_rogach_scallop_2_11",
        artifact = "org.rogach:scallop_2.11:3.1.3",
        artifact_sha256 = "ed860257bd1aa8120b35c7e03b3ba5764dbf4b7d96267bc0c145500245fee3c0",
        server_urls = ["https://repo.maven.apache.org/maven2"],
    )

    maven_install(
        name = "hocon_maven",
        artifacts = [
            "org.scala-sbt:compiler-interface:1.2.1",
            "org.scala-sbt:util-interface:1.2.0",
            "org.scala-lang:scala-compiler:2.11.12",
            "org.scala-lang:scala-library:2.11.12",
            "org.scala-lang:scala-reflect:2.11.12",
        ],
        repositories = [
            "http://central.maven.org/maven2",
        ],
        fetch_sources = True,
        maven_install_json = "@io_bazel_rules_hocon//:hocon_maven_install.json",
    )
