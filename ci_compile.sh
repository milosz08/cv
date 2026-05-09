#!/bin/bash

set -e

apt-get update
apt-get install -y --no-install-recommends \
  make \
  texlive-latex-recommended \
  texlive-latex-extra \
  texlive-fonts-recommended \
  texlive-lang-polish \
  texlive-lang-english \
  latexmk \
  ca-certificates \
  cm-super \
  lmodern

make build
