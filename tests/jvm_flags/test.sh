#! /bin/bash

set -euo pipefail

cd "$(bazel info workspace 2> /dev/null)"

bazel test //tests/jvm_flags:jvm-flags-test
