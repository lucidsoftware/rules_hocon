#! /bin/bash

set +e

cd $(bazel info workspace 2> /dev/null)

out=$(bazel build //tests/optional_includes:good 2>&1)
if [[ $? -ne 0 ]]; then echo "$out"; exit 1; fi

# Verify 3.conf was included
config_path="bazel-bin/tests/optional_includes/good.conf"
cat "$config_path" | grep -oq "some-config=hello"
if [[ $? -ne 0 ]]; then echo "Malformed config: "; cat "$config_path"; exit 1; fi

out=$(! bazel build //tests/optional_includes:bad 2>&1)
if [[ $? -ne 0 ]]; then echo "FAILURE: Build should have failed due to a missing environment key"; exit 1; fi
