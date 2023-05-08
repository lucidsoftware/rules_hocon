load("@rules_jvm_external//:defs.bzl", "maven_install")

def hocon_repositories():
    maven_install(
        name = "hocon_maven",
        artifacts = [
            "com.typesafe:config:1.4.2",
            "org.rogach:scallop_2.13:3.3.2",
            # Core scala libraries, compiler, etc.
            "org.scala-lang:scala-compiler:2.13.3",
            "org.scala-lang:scala-library:2.13.3",
            "org.scala-lang:scala-reflect:2.13.3",
            "org.scala-sbt:compiler-bridge_2.13:1.3.4",
        ],
        repositories = [
            "https://repo.maven.apache.org/maven2",
            "https://maven-central.storage-download.googleapis.com/maven2",
            "https://mirror.bazel.build/repo1.maven.org/maven2",
        ],
        fetch_sources = True,
        maven_install_json = "@io_bazel_rules_hocon//:hocon_maven_install.json",
    )
