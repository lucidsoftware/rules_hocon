load("@rules_jvm_external//:defs.bzl", "maven_install")

def hocon_repositories():
    maven_install(
        name = "hocon_maven",
        artifacts = [
            "com.typesafe:config:1.3.3",
            "org.rogach:scallop_2.12:3.3.2",
            "org.scala-sbt:compiler-interface:1.2.1",
            "org.scala-sbt:util-interface:1.2.0",
            "org.scala-lang:scala-compiler:2.12.8",
            "org.scala-lang:scala-library:2.12.8",
            "org.scala-lang:scala-reflect:2.12.8",
        ],
        repositories = [
            "https://repo.maven.apache.org/maven2",
        ],
        fetch_sources = True,
        maven_install_json = "@io_bazel_rules_hocon//:hocon_maven_install.json",
    )
