#!/bin/sh -e
cd "$(dirname "$0")"

bazel run @hocon_maven//:pin
