# Makefile para Hackaton Platform

.PHONY: help init plan apply destroy test lint format clean deploy

help:
	@echo "Hackaton Platform - Makefile"
	@echo ""
	@echo "Targets:"
	@echo "  make init       - Inicializar Terraform"
	@echo "  make plan       - Planejar changes do Terraform"
	@echo "  make apply      - Aplicar changes do Terraform"
	@echo "  make destroy    - Destruir infraestrutura"
	@echo "  make test       - Rodar testes"
	@echo "  make lint       - Verificar código (linting)"
	@echo "  make format     - Formatar código"
	@echo "  make clean      - Limpar arquivos temporários"
	@echo "  make deploy     - Deploy completo (infra + backend + frontend)"

# Terraform targets
init:
	cd terraform && terraform init

plan:
	cd terraform && terraform plan

apply:
	cd terraform && terraform apply -auto-approve

destroy:
	cd terraform && terraform destroy -auto-approve

# Testing targets
test:
	cd src && pytest -v --cov=.

test-backend:
	cd src && pytest -v

test-frontend:
	cd frontend && npm test -- --watchAll=false

# Code quality targets
lint:
	cd src && flake8 . && mypy .
	cd frontend && npm run lint

format:
	cd src && black . && isort .

format-frontend:
	cd frontend && npx prettier --write "src/**/*.{js,jsx,css}"

# Build targets
build-backend:
	cd src && zip -r ../terraform/modules/api/lambda_code.zip . -x "*.pyc" "__pycache__/*" "tests/*"

build-frontend:
	cd frontend && npm run build

# Clean targets
clean:
	cd src && find . -type f -name "*.pyc" -delete && find . -type d -name "__pycache__" -delete
	cd terraform && rm -rf .terraform/ *.tfstate* tfplan
	cd frontend && rm -rf node_modules/ build/
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true

# Deploy targets
deploy-backend: build-backend
	@echo "Backend empacotado em terraform/modules/api/lambda_code.zip"
	@echo "Execute 'make apply' para fazer deploy via Terraform"

deploy-frontend: build-frontend
	@echo "Frontend pronto em frontend/build/"
	@echo "Execute 'npm run deploy' para fazer upload para S3"

deploy-infra: clean init apply
	@echo "Infraestrutura deployada com sucesso!"
	@cd terraform && terraform output

deploy: deploy-infra deploy-backend
	@echo "Deploy do backend e infraestrutura concluído!"

# Development targets
dev-backend:
	cd src && python -m pytest --watch

dev-frontend:
	cd frontend && npm start

# Docker targets
docker-build:
	docker build -t hackaton-platform:latest .

docker-run:
	docker run -p 3000:3000 -e AWS_REGION=us-east-1 hackaton-platform:latest

# Utility targets
logs-api:
	aws logs tail /aws/apigateway/hackaton-platform --follow

logs-lambda:
	aws logs tail /aws/lambda/hackaton-platform-crud-handler --follow

metrics:
	aws cloudwatch get-metric-statistics \
		--namespace AWS/Lambda \
		--metric-name Duration \
		--start-time 2024-01-01T00:00:00Z \
		--end-time 2024-12-31T23:59:59Z \
		--period 3600 \
		--statistics Average,Maximum

install-dev:
	cd src && pip install -r requirements-dev.txt
	cd frontend && npm install

version:
	@echo "Hackaton Platform v1.0.0"
