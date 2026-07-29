# rules_hocon
Bazel rules for verifying and merging HOCON config files

| Status |
| --- |
| [![Build Status](https://github.com/lucidsoftware/rules_hocon/workflows/CI/badge.svg)](https://github.com/lucidsoftware/rules_hocon/actions) |

## Overview

`rules_hocon` compiles and validates [HOCON](https://github.com/lightbend/config) configuration
files using Bazel. It merges multiple HOCON source files into a flattened configuration artifact
and verifies that any references (`${}` syntax) either refer to internal config or keys from an
allowlist of config that will be provided at runtime.

## Installation

*MODULE.bazel*

```starlark
bazel_dep(name = "rules_hocon")

rules_hocon_version = "<COMMIT>"

archive_override(
    module_name = "rules_hocon",
    integrity = "<INTEGRITY>",
    strip_prefix = "rules_hocon-{}".format(rules_hocon_version),
    urls = ["https://github.com/lucidsoftware/rules_hocon/archive/{}.zip".format(rules_hocon_version)],
)
```

By default, the Scala 3 version of the HOCON compiler will be used. If you want to use a custom
HOCON compiler, you can set up a custom toolchain like so:

*BUILD.bazel*

```starlark
load("@rules_hocon//hocon-toolchain:create-toolchain.bzl", "create_hocon_toolchain")

create_hocon_toolchain(
    name = "hocon-custom",
    hocon_compiler = "<label of your custom HOCON compiler>",
)
```

Then, register your toolchain with Bazel:

*MODULE.bazel*

```starlark
register_toolchains("//:hocon-custom")
```

## Usage

The `hocon_library` rule compiles HOCON source files into a flattened Hocon config file. It
supports merging with base configs, validating environment variable references, and optional
includes.

```starlark
load("@rules_hocon//rules:hocon.bzl", "hocon_library")

hocon_library(
    name = "my-config",
    src = "config/application.conf",
    out = "application.conf",
    base = "config/base.conf",
    deps = ["config/overrides.conf"],
    env_key_lists = ["config/env_keys"],
    resolve = True,
)
```

## Development

### HOCON Compiler CLI

This project consists of the HOCON Bazel rules and a command line HOCON compiler. The command line
compiler can be built with

```bash
bazel build //hocon-compiler-cli
```

### Testing

All tests can be run using

```bash
tests/run_tests.sh
```

### Updating Third Party Dependencies

We use [rules_jvm_external](https://github.com/bazelbuild/rules_jvm_external) to import third party
dependencies.

To make changes to the dependencies, simply update the appropriate `maven.install` call in
`MODULE.bazel`, and then update the dependencies json file used by `rules_jvm_external` by running
the following script:

```bash
scripts/gen-deps.sh
```
