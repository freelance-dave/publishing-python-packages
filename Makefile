.DEFAULT_GOAL := help

####
## Build and install ### 

init: ## Initalise the projects virtual env: (uses builtin wildcard function)
ifeq (,$(wildcard ./.venv))
	python3 -m venv ./.venv
endif
ifneq (,$(wildcard ./requirements.txt))
	python3 -m pip install -r ./requirements.txt
endif
	@python3 -m pip install --upgrade pip setuptools wheel
	@python3 -m pip list

githook: ## Runs pre-commit hooks against all source files.
	@pre-commit install
	pre-commit run --all-files

package: ## Builds the package only, uses: pyproject.toml, setup.cfg, setup.py
	python -m build --sdist

build: ## Builds both the package and wheel, uses: pyproject.toml, setup.cfg setup.py
	pyproject-build

install: ## Install Built package into local .venv environment.
	python3 -m pip install .

publish: ## Publishe package source to PyPI.org
	pyproject-build --sdist
	twine upload dist/*
	
run: install ## run package's created command line tool
	.venv/bin/harmony 0.65 0.7

.PHONY : docs
docs: ## Generate project documentation utilising python sphinx
	tox -e docs
	python3 -m http.server -d docs/_build/ 9876

.PHONY : test
test: ## run tox unitests tests, mypy, black and flake8 in parallel: 
	tox -p -e py39,py310,typecheck,format,lint

.PHONY : clean
clean: ## Clean up build directories and generated files (*.egg-info, *.c).
	@rm -rf ./.coverage ./.mypy_cache ./.tox ./build ./dist ./wheelhouse ./wheels
	@rm -rf ./docs/_build ./docs/_templates ./docs/reference
	@find . -type d -name "__pycache__" -not -path "./.venv/*" -exec rm -rf {} +
	@find ./src -type d -name "*.egg-info" -exec rm -rf {} +
	@find ./src -type f -name '*.c' -exec sh -c \
		'for f do [ -e "$${f%.*}.pyx" ] && rm -f -- "$$f";done' sh {} +

.PHONY : help
help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
	| sed -n 's/^\(.*\): \(.*\)##\(.*\)/\1\t\3/p' 

