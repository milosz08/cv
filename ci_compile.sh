#!/bin/bash

set -e

apt-get update
apt-get install -y --no-install-recommends \
  texlive-latex-recommended \
  texlive-latex-extra \
  texlive-fonts-recommended \
  texlive-lang-polish \
  texlive-lang-english \
  latexmk \
  ca-certificates \
  cm-super \
  lmodern

latexmk -pdf -interaction=nonstopmode -halt-on-error cv_pl.tex
latexmk -pdf -interaction=nonstopmode -halt-on-error cv_en.tex
