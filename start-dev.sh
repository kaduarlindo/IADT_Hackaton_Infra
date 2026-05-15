#!/bin/bash

# Script de inicialização do desenvolvimento local

set -e

echo "🚀 Iniciando ambiente de desenvolvimento..."
echo ""

# Cores
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Verificar se docker está instalado
if ! command -v docker &> /dev/null; then
    echo "Docker não encontrado. Instale em: https://docker.com"
    exit 1
fi

# Verificar se docker-compose está instalado
if ! command -v docker-compose &> /dev/null; then
    echo "Docker Compose não encontrado. Instale em: https://docker.com"
    exit 1
fi

echo -e "${YELLOW}[1]${NC} Iniciando serviços..."
docker-compose up -d

echo -e "${GREEN}✓${NC} Serviços iniciados"
echo ""

echo -e "${YELLOW}[2]${NC} Aguardando LocalStack estar pronto..."
sleep 5

echo -e "${YELLOW}[3]${NC} Criando buckets S3..."
aws s3 mb s3://hackaton-uploads \
  --endpoint-url http://localhost:4566 \
  --region us-east-1 || true

echo -e "${GREEN}✓${NC} Bucket criado"
echo ""

echo -e "${YELLOW}[4]${NC} Criando tabela DynamoDB..."
aws dynamodb create-table \
  --table-name hackaton-documents \
  --attribute-definitions \
    AttributeName=documentId,AttributeType=S \
    AttributeName=timestamp,AttributeType=N \
  --key-schema \
    AttributeName=documentId,KeyType=HASH \
    AttributeName=timestamp,KeyType=RANGE \
  --billing-mode PAY_PER_REQUEST \
  --endpoint-url http://localhost:8000 \
  --region us-east-1 \
  2>/dev/null || echo "Tabela já existe"

echo -e "${GREEN}✓${NC} Tabela criada"
echo ""

echo -e "${GREEN}✅ Ambiente pronto!${NC}"
echo ""
echo "📋 Endpoints:"
echo "  Frontend:     http://localhost:3001"
echo "  Backend API:  http://localhost:3000"
echo "  LocalStack:   http://localhost:4566"
echo "  DynamoDB:     http://localhost:8000"
echo "  MinIO:        http://localhost:9001"
echo ""
echo "Parar com: docker-compose down"
