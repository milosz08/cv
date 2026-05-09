DOC = cv
LATEX = latexmk

FLAGS_BUILD = -pdf -interaction=nonstopmode
FLAGS_WATCH = -pdf -pvc -interaction=nonstopmode

-include .env
export

.PHONY: generate-env-tex
generate-env-tex:
	@printf '\\newcommand{\\VARPHONE}{%s}\n' "$(CV_PHONE_NUMBER)" > env.tex

.PHONY: build
build: generate-env-tex
	$(LATEX) $(FLAGS_BUILD) $(DOC)_en.tex
	$(LATEX) $(FLAGS_BUILD) $(DOC)_pl.tex

.PHONY: watch-en
watch-en: generate-env-tex
	$(LATEX) $(FLAGS_WATCH) $(DOC)_en.tex

.PHONY: watch-pl
watch-pl: generate-env-tex
	$(LATEX) $(FLAGS_WATCH) $(DOC)_pl.tex

.PHONY: watch
watch: generate-env-tex
	$(LATEX) $(FLAGS_WATCH) $(DOC)_en.tex & \
	$(LATEX) $(FLAGS_WATCH) $(DOC)_pl.tex

.PHONY: clean
clean:
	$(LATEX) -c $(DOC)_en.tex
	$(LATEX) -c $(DOC)_pl.tex
	rm -f env.tex

.PHONY: infra-init
infra-init:
	@cd terraform && terraform init

.PHONY: infra-plan
infra-plan:
	@cd terraform && terraform plan \
		-var="project_id=$(PROJECT_ID)" \
		-var="cf_secret_token=$(CF_SECRET_TOKEN)"

.PHONY: infra-apply
infra-apply:
	@cd terraform && terraform apply -auto-approve \
		-var="project_id=$(PROJECT_ID)" \
		-var="cf_secret_token=$(CF_SECRET_TOKEN)"

.PHONY: infra-url
infra-url:
	@cd terraform && terraform output cloud_function_url

.PHONY: build-worker
build-worker:
	@cd waf && chmod +x generate_worker.sh
	@cd waf && SECRET_TOKEN=$(CF_SECRET_TOKEN) ./generate_worker.sh
