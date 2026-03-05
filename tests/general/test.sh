#! /bin/bash

set -e

cd $(bazel info workspace 2> /dev/null)

bazel build //tests/general

output="bazel-bin/tests/general/resolved.conf"
expected_hash="9d1b57f83666b74b73fb305fbb6d140655c33cc6"
resolved_hash=$(awk '{print $1}' <<<  $(shasum $output))

if [[ $resolved_hash != $expected_hash ]]; then
	echo "ERROR: resolved config is malformed. Got $resolved_hash but expected $expected_hash"
	echo "Generated config:"
	cat $output
	exit 1
fi
