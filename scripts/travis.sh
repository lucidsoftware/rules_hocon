#!/bin/bash

# Borrowed from higherkindness/rules_scala
# https://github.com/higherkindness/rules_scala

#
# Acts as a front end script for use with Travis CI
#

set -eox pipefail
cd "$(dirname "$0")/.."

case "$1" in
    "lint")
        ./scripts/format.sh check
        ;;
    "test")
        ./tests/run_tests.sh
        ;;
    "")
        echo "command not specified"
        exit 1
        ;;
    *)
        echo "$1 not understood"
        exit 1
        ;;
esac
