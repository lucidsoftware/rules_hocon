#!/bin/sh -e
cd "$(dirname "$0")"

REPIN=1 bazel run @hocon_maven//:pin
