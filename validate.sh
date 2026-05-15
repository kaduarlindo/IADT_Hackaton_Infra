#!/bin/bash

# Script para validar estrutura do projeto

set -e

echo "🔍 Validando Estrutura da Arquitetura Hackaton Platform"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Contadores
total=0
valid=0
invalid=0

# Função para verificar arquivo/diretório
check() {
    local path=$1
    local type=$2
    local name=$3
    
    ((total++))
    
    if [ "$type" = "dir" ] && [ -d "$path" ]; then
        echo -e "${GREEN}✓${NC} $name"
        ((valid++))
    elif [ "$type" = "file" ] && [ -f "$path" ]; then
        echo -e "${GREEN}✓${NC} $name"
        ((valid++))
    else
        echo -e "${RED}✗${NC} $name (faltando)"
        ((invalid++))
    fi
}

echo "=== Terraform ==="
check "terraform" "dir" "Diretório terraform/"
check "terraform/main.tf" "file" "main.tf"
check "terraform/variables.tf" "file" "variables.tf"
check "terraform/terraform.tfvars" "file" "terraform.tfvars"
check "terraform/modules/s3" "dir" "Módulo S3"
check "terraform/modules/dynamodb" "dir" "Módulo DynamoDB"
check "terraform/modules/api" "dir" "Módulo API"
check "terraform/modules/iam" "dir" "Módulo IAM"
check "terraform/modules/cloudfront" "dir" "Módulo CloudFront"
echo ""

echo "=== Backend (Python) ==="
check "src" "dir" "Diretório src/"
check "src/lambda_handlers.py" "file" "Lambda handlers"
check "src/domain" "dir" "Domínio"
check "src/ports" "dir" "Portas"
check "src/application" "dir" "Aplicação"
check "src/adapters" "dir" "Adaptadores"
check "src/adapters/inbound" "dir" "Adaptadores de entrada"
check "src/adapters/outbound" "dir" "Adaptadores de saída"
check "src/requirements.txt" "file" "Requirements"
check "src/requirements-dev.txt" "file" "Requirements dev"
echo ""

echo "=== Frontend (React) ==="
check "frontend" "dir" "Diretório frontend/"
check "frontend/package.json" "file" "package.json"
check "frontend/src/App.js" "file" "App.js"
check "frontend/src/App.css" "file" "App.css"
check "frontend/public/index.html" "file" "index.html"
echo ""

echo "=== Documentação ==="
check "docs" "dir" "Diretório docs/"
check "docs/API.md" "file" "API.md"
check "docs/ARQUITETURA.md" "file" "ARQUITETURA.md"
check "docs/DEPLOYMENT.md" "file" "DEPLOYMENT.md"
check "docs/DESENVOLVIMENTO.md" "file" "DESENVOLVIMENTO.md"
check "docs/index.html" "file" "index.html"
check "README.md" "file" "README.md"
check "QUICKSTART.md" "file" "QUICKSTART.md"
echo ""

echo "=== Scripts & Configuração ==="
check "Makefile" "file" "Makefile"
check "docker-compose.yml" "file" "docker-compose.yml"
check "build.sh" "file" "build.sh"
check "test.sh" "file" "test.sh"
check "start-dev.sh" "file" "start-dev.sh"
check ".env.example" "file" ".env.example"
check ".gitignore" "file" ".gitignore"
echo ""

# Resumo
echo "=== RESUMO ==="
echo -e "Total de arquivos/diretórios verificados: $total"
echo -e "${GREEN}Válidos: $valid${NC}"
if [ $invalid -gt 0 ]; then
    echo -e "${RED}Inválidos: $invalid${NC}"
else
    echo -e "${GREEN}Inválidos: 0${NC}"
fi

if [ $invalid -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✅ Estrutura do projeto validada com sucesso!${NC}"
    echo ""
    echo "Próximos passos:"
    echo "1. Leia QUICKSTART.md para começar"
    echo "2. Execute './start-dev.sh' para ambiente local"
    echo "3. Ou 'cd terraform && terraform init' para deploy"
    echo ""
else
    echo ""
    echo -e "${RED}❌ Alguns arquivos estão faltando!${NC}"
    exit 1
fi
