#!/bin/bash

# Script para fazer build e deploy do backend

set -e

echo "🔨 Build do Backend Hackaton Platform"
echo ""

# Cores
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Diretórios
SRC_DIR="src"
BUILD_DIR="build"
DIST_DIR="dist"

echo -e "${YELLOW}[1/5]${NC} Verificando dependências..."
if ! command -v zip &> /dev/null; then
    echo -e "${RED}❌ zip não encontrado. Instale com: apt-get install zip${NC}"
    exit 1
fi

if ! command -v python3 &> /dev/null; then
    echo -e "${RED}❌ python3 não encontrado${NC}"
    exit 1
fi

echo -e "${GREEN}✓${NC} Dependências OK"
echo ""

echo -e "${YELLOW}[2/5]${NC} Criando estrutura de diretórios..."
mkdir -p "$BUILD_DIR"
mkdir -p "$DIST_DIR"
echo -e "${GREEN}✓${NC} Diretórios criados"
echo ""

echo -e "${YELLOW}[3/5]${NC} Instalando dependências Python..."
pip install --target "$BUILD_DIR" -r "$SRC_DIR/requirements.txt" -q
echo -e "${GREEN}✓${NC} Dependências instaladas"
echo ""

echo -e "${YELLOW}[4/5]${NC} Copiando código fonte..."
cp -r "$SRC_DIR"/* "$BUILD_DIR/"
echo -e "${GREEN}✓${NC} Código copiado"
echo ""

echo -e "${YELLOW}[5/5]${NC} Criando arquivo ZIP..."
cd "$BUILD_DIR"
zip -r -q "../$DIST_DIR/lambda_code.zip" .
cd ..

# Obter tamanho do arquivo
SIZE=$(du -h "$DIST_DIR/lambda_code.zip" | cut -f1)

echo -e "${GREEN}✓${NC} ZIP criado: $SIZE"
echo ""

echo -e "${GREEN}✅ Build completo!${NC}"
echo ""
echo "📦 Arquivo: $DIST_DIR/lambda_code.zip"
echo ""
echo "Para fazer deploy:"
echo "  cd terraform"
echo "  cp ../$DIST_DIR/lambda_code.zip modules/api/"
echo "  terraform apply"
