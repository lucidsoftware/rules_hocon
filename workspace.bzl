load("@rules_jvm_external//:defs.bzl", "maven_install")

scala_version = "2.13.12"

def hocon_repositories():
    maven_install(
        name = "hocon_maven",
        artifacts = [
            "com.typesafe:config:1.4.3",
            "org.rogach:scallop_2.13:5.0.1",
            # Core scala libraries, compiler, etc.
            "org.scala-lang:scala-compiler:{}".format(scala_version),
            "org.scala-lang:scala-library:{}".format(scala_version),
            "org.scala-lang:scala-reflect:{}".format(scala_version),
            "org.scala-sbt:compiler-bridge_2.13:1.9.5",
        ],
        repositories = [
            "https://repo.maven.apache.org/maven2",
            "https://maven-central.storage-download.googleapis.com/maven2",
            "https://mirror.bazel.build/repo1.maven.org/maven2",
        ],
        fetch_sources = True,
        maven_install_json = "@io_bazel_rules_hocon//:hocon_maven_install.json",
    )
