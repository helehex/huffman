#!/usr/bin/env bash
# x----------------------------------------------------------------------------------------------x #
# | Copyright (c) 2024 Helehex
# x----------------------------------------------------------------------------------------------x #

set -euo pipefail

REPO_NAME="huffman"

BUILD_DIR=$(cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
REPO_ROOT=$(realpath "${BUILD_DIR}/..")
SRC_PATH="${REPO_ROOT}/src"

PACKAGE_NAME=${REPO_NAME}".mojopkg"
PACKAGE_PATH=${BUILD_DIR}"/"${PACKAGE_NAME}

echo "╓───  Packaging the Huffman library"
mojo package "${SRC_PATH}" -o "${PACKAGE_PATH}"
echo Successfully created "${PACKAGE_PATH}"