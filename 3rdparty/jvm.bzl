# Do not edit. bazel-deps autogenerates this file from dependencies.yaml.
def list_dependencies():
    return [
        {
            "bind_args": {
                "actual": "@com_github_scopt_scopt_2_11",
                "name": "jar/com/github/scopt/scopt_2_11"
            },
            "import_args": {
                "default_visibility": [ "//visibility:public" ],
                "deps": [ "@scala_scala_library//jar" ],
                "jar_sha256": "cc05b6ac379f9b45b6d832b7be556312039f3d57928b62190d3dcd04f34470b5",
                "jar_urls": [
                    "https://oss.sonatype.org/content/repositories/releases/com/github/scopt/scopt_2.11/3.7.0/scopt_2.11-3.7.0.jar"
                ],
                "licenses": [ "notice" ],
                "name": "com_github_scopt_scopt_2_11",
                "srcjar_sha256": "1c9111bafb55ec192d04898123199e51440e1633118b112d0c14a611491805ef",
                "srcjar_urls": [
                    "https://oss.sonatype.org/content/repositories/releases/com/github/scopt/scopt_2.11/3.7.0/scopt_2.11-3.7.0-sources.jar"
                ]
            },
            "lang": "scala"
        },
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
        }
    ]
    