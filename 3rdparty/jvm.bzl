# Do not edit. bazel-deps autogenerates this file from dependencies.yaml.
def list_dependencies():
    return [
        {
            "bind_args": {
                "actual": "@com_typesafe_config",
                "name": "jar/com/typesafe/config"
            },
            "import_args": {
                "default_visibility": [ "//visibility:public" ],
                "jar_sha256": "b5f1d6071f1548d05be82f59f9039c7d37a1787bd8e3c677e31ee275af4a4621",
                "jar_urls": [
                    "https://oss.sonatype.org/content/repositories/releases/com/typesafe/config/1.3.3/config-1.3.3.jar"
                ],
                "licenses": [ "notice" ],
                "name": "com_typesafe_config",
                "srcjar_sha256": "fcd7c3070417c776b313cc559665c035d74e3a2b40a89bbb0e9bff6e567c9cc8",
                "srcjar_urls": [
                    "https://oss.sonatype.org/content/repositories/releases/com/typesafe/config/1.3.3/config-1.3.3-sources.jar"
                ]
            },
            "lang": "java"
        },
        {
            "bind_args": {
                "actual": "@org_rogach_scallop_2_11",
                "name": "jar/org/rogach/scallop_2_11"
            },
            "import_args": {
                "default_visibility": [ "//visibility:public" ],
                "deps": [ "@scala_scala_library//jar" ],
                "jar_sha256": "ed860257bd1aa8120b35c7e03b3ba5764dbf4b7d96267bc0c145500245fee3c0",
                "jar_urls": [
                    "https://oss.sonatype.org/content/repositories/releases/org/rogach/scallop_2.11/3.1.3/scallop_2.11-3.1.3.jar"
                ],
                "licenses": [ "notice" ],
                "name": "org_rogach_scallop_2_11",
                "srcjar_sha256": "e471198a7330a86535a3cc603da3b80889c377782d8d7aa4b72385a40752f651",
                "srcjar_urls": [
                    "https://oss.sonatype.org/content/repositories/releases/org/rogach/scallop_2.11/3.1.3/scallop_2.11-3.1.3-sources.jar"
                ]
            },
            "lang": "scala"
        }
    ]
    