#!/bin/bash -e

# Borrowed from higherkindness/rules_scala
# https://github.com/higherkindness/rules_scala

#
# Reformats various files (.bzl, .scala) throughout the project
#

set -o pipefail
cd "$(dirname "$0")/.."

scalafmtbin="$(mktemp)"

bazel run --script_path "$scalafmtbin" @rules_scala_annex//rules/scalafmt

_scalafmt() {
  find hocon-compiler -name '*.scala' -exec $scalafmtbin --config "$PWD/.scalafmt.conf" "$PWD/{}" "$PWD/{}" \;
}

_scalafmt-check() {
  tfile="$(mktemp)"
  failed=0
  while IFS= read -r -d $'\0' f; do
    # `/tmp` may be mounted as `noexec`, in which case we can't execute `"$scalafmtbin"` directly
    bash $scalafmtbin --config "$PWD/.scalafmt.conf" "$PWD/$f" "$tfile"
    if ! diff -u "$f" "$tfile"; then
      (( failed++ )) || true
    fi
  done < <(find hocon-compiler -name '*.scala' -print0)

  if (( failed > 0 )); then
    printf "ERROR: %d files were not correctly formatted. Please run scripts/format.sh" $failed >&2
    exit 1
  fi
}

if [ "$1" != check ]; then
    bazel run //dev:buildifier
    _scalafmt
else
    bazel run //dev:buildifier_check
    _scalafmt-check
fi
