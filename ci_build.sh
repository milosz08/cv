#!/bin/bash

set -e

docker run --rm \
  -v "$PWD:/workspace" \
  -w /workspace \
  -e DEBIAN_FRONTEND=noninteractive \
  -e CV_PHONE_NUMBER="$CV_PHONE_NUMBER" \
  ubuntu:24.04 ./ci_compile.sh
