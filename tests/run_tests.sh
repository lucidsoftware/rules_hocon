#! /bin/bash -e

for test in $(find $(dirname $0) -name "test.sh"); do
  echo "running $test..."
  bash $test || echo "FAILURE: $test failed."
done;
