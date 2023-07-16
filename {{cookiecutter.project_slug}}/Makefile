# Poetic Conda setup, see https://github.com/kxmh42/poetic-conda
.PHONY: check-name clean-direct-url-json env update
SHELL := /usr/bin/env bash

# Note: it doesn't work for paths with spaces. It's probably impossible to make
# it work with such paths due to the format of MAKEFILE_LIST.
export PROJECT_DIR := $(dir $(lastword $(MAKEFILE_LIST)))

# Make micromamba configuration local to the project to maintain reproducibility
export MAMBARC := $(PROJECT_DIR)/.mambarc

# These direct_url.json files don't contain anything useful and can be deleted.
# They cause Poetry overwrite existing Conda packages even if versions match.
# See https://github.com/python-poetry/poetry/issues/6408
define clean_direct_url_json
find "$CONDA_PREFIX" -name direct_url.json -print0 \
| xargs -0 egrep -l --null '"url": "file://(/home/conda|/Users/runner/miniforge3/conda-bld)' \
| xargs -0 rm -f
endef

check-name:
	@if [ -z "$(name)" ]; then echo "Usage: make env name=my_env_name"; false; fi

.envrc: check-name
	activate='eval "`micromamba shell hook -s bash`" && micromamba activate $(name)' \
	&& fgrep -q "$$activate" .envrc 2>/dev/null \
	|| echo "$$activate" >>.envrc
	@echo "Run \`direnv allow\` to automatically activate the environment when you enter the project directory"

clean-direct-url-json:
	$(value clean_direct_url_json)

env: check-name{% if cookiecutter.generate_envrc %} .envrc{% endif %}
	micromamba create -n "$(name)" -f conda-lock.yml
	eval "`micromamba shell hook -s bash`" \
	&& micromamba activate $(name) \
	&& $(value clean_direct_url_json) \
	&& poetry install

update:
	conda-lock --conda micromamba --micromamba
	micromamba update --file conda-lock.yml
	$(value clean_direct_url_json)
	poetry update
