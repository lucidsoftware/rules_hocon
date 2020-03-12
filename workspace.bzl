load("@rules_jvm_external//:defs.bzl", "maven_install")

def hocon_repositories():
    maven_install(
        name = "hocon_maven",
        artifacts = [
            "com.typesafe:config:1.3.3",
            "org.rogach:scallop_2.12:3.3.2",
        ],
        repositories = [
            "https://repo.maven.apache.org/maven2",
            "https://maven-central.storage-download.googleapis.com/maven2",
            "https://mirror.bazel.build/repo1.maven.org/maven2",
        ],
        fetch_sources = True,
        maven_install_json = "@io_bazel_rules_hocon//:hocon_maven_install.json",
    )
