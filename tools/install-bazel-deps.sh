#!/bin/bash -e

bazel_output_base="$(bazel info output_base)"
tools_directory="$bazel_output_base/external-tools/"
output_directory="$tools_directory/bazel-deps"
version_file="$tools_directory/bazel-deps.version"
executable_file="$tools_directory/bazel-deps.sh"
url="https://github.com/lucidsoftware/bazel-deps/archive/2b1f550f6a6ececdda4233a47b8429b9f98826f1.tar.gz"

if [[ "$url" = "$(< $version_file)" ]]; then
  echo "bazel-deps already installed"
  exit 0
fi

echo "Downloading $url"
rm -rf "$output_directory" "$version_file" "$executable_file"
mkdir -p "$output_directory"
curl -L -sS "$url" | tar xzf - --strip 1 -C "$output_directory"
cd "$output_directory"
echo "Building bazel-deps"
bazel run --color=yes --script_path="$executable_file" parse && echo "$url" > "$version_file"

