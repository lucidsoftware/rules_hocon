#!/bin/bash -e

# Borrowed from higherkindness/rules_scala
# https://github.com/higherkindness/rules_scala

#
# Reformats various files (.bzl, .scala) throughout the project
#

set -o pipefail
cd "$(dirname "$0")/.."

if [ "$1" != check ]; then
    bazel run buildifier
    bazel run :scalafmt
else
    bazel run buildifier_check
    bazel run :scalafmt-test
fi
