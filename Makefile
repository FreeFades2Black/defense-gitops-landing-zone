.PHONY: init lint scan test plan dossier clean

init:
	python -m pip install --upgrade pip
	pip install -r requirements.txt

lint:
	ruff check .
	mypy src/

test:
	pytest tests/ -v --tb=short

scan:
	checkov -d terraform/ --framework terraform || true

plan:
	cd terraform && terraform init -backend=false && terraform validate

dossier:
	python scripts/generate_security_report.py

clean:
	rm -rf .pytest_cache .mypy_cache SECURITY_RELEASE_DOSSIER.md
