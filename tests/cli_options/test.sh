#! /bin/bash

set -e

cd "$(bazel info workspace 2> /dev/null)"

bazel build //hocon-compiler-cli:hocon-compiler-cli-3

help_output="$(bazel-bin/hocon-compiler-cli/hocon-compiler-cli-3-bin -h 2>&1)"

if ! grep -Fq -- "-h, --help" <<< "$help_output"; then
	echo "ERROR: -h did not print the expected help option."
	echo "$help_output"
	exit 1
fi

if ! grep -Fq -- "-H, --header" <<< "$help_output"; then
	echo "ERROR: The header option was not exposed as -H, --header."
	echo "$help_output"
	exit 1
fi
