#! /bin/bash

set -e

cd $(bazel info workspace 2> /dev/null)

bazel clean
bazel build //tests/general

output="bazel-bin/tests/general/resolved.conf"
expected_hash="3f9870d95cb3021763649c2f078f3265417c60b2"
resolved_hash=$(awk '{print $1}' <<<  $(shasum $output))

if [[ $resolved_hash != $expected_hash ]]; then
	echo "ERROR: resolved config is malformed. Got $resolved_hash but expected $expected_hash"
	echo "Generated config:"
	cat $output
	exit 1
fi
