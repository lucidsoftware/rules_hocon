#! /bin/bash -e

failed="false"

for test in $(find $(dirname $0) -name "test.sh"); do
  echo "running $test..."
  bash $test || { failed="true"; echo "FAILURE: $test failed."; }
done;

if [[ "$failed" == "true" ]]; then
  exit 1;
fi
