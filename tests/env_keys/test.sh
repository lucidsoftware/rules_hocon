#! /bin/bash

set +e

cd $(bazel info workspace 2> /dev/null)

out=$(bazel build //tests/env_keys:good 2>&1)
if [[ $? -ne 0 ]]; then echo "$out"; exit 1; fi

out=$(! bazel build //tests/env_keys:bad 2>&1)
if [[ $? -ne 0 ]]; then echo "FAILURE: Build should have failed due to a missing environment key"; exit 1; fi
