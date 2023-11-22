#! /bin/bash

set -e

cd "$(bazel info workspace 2> /dev/null)"

bazel build //tests/general

output="bazel-bin/tests/general/resolved.conf"
expected="tests/general/expected.conf"

if ! diff -u "$expected" "$output"; then
	echo "ERROR: resolved config is malformed."
	echo "See diff above"
	exit 1
fi
