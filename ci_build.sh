#!/bin/bash

set -e

docker run --rm -v "$PWD:/workspace" -w /workspace -e DEBIAN_FRONTEND=noninteractive ubuntu:24.04 ./ci_compile.sh
