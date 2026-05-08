DOC = cv
LATEX = latexmk

FLAGS_BUILD = -pdf -interaction=nonstopmode
FLAGS_WATCH = -pdf -pvc -interaction=nonstopmode

.PHONY: all build watch-en watch-pl watch clean

all: build

build:
	$(LATEX) $(FLAGS_BUILD) $(DOC)_en.tex
	$(LATEX) $(FLAGS_BUILD) $(DOC)_pl.tex

watch-en:
	$(LATEX) $(FLAGS_WATCH) $(DOC)_en.tex

watch-pl:
	$(LATEX) $(FLAGS_WATCH) $(DOC)_pl.tex

watch:
	$(LATEX) $(FLAGS_WATCH) $(DOC)_en.tex & \
	$(LATEX) $(FLAGS_WATCH) $(DOC)_pl.tex

clean:
	$(LATEX) -c main$(DOC)_en.tex
	$(LATEX) -c $(DOC)_pl.tex
