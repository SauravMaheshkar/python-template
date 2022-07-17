## Install Dependencies
requirements:
	pip install -U pip setuptools wheel
	pip install -r requirements.txt

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type f -name "__pycache__" -delete

## Basic linting
lint:
	black src
	isort src --profile=black
	mypy src
	pylint src

