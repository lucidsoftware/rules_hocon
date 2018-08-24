load(":jvm.bzl", "list_dependencies")

load("@rules_scala_annex//rules:external.bzl", "scala_import_external")

def maven_repositories():
  for hash in list_dependencies():
    import_args = hash["import_args"]
    scala_import_external(**import_args)
