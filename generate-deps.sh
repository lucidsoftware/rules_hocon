#!/bin/bash -e
cd "$(dirname "$0")"

echo "Generating dependencies for main workspace"
bazel-deps generate -r "$(pwd)" -s 3rdparty/jvm.bzl -d dependencies.yaml
