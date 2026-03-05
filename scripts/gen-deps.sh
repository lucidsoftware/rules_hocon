#!/bin/sh -e
cd "$(dirname "$0")"

bazel run @unpinned_hocon_maven//:pin
