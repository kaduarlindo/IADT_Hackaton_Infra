#!/bin/bash

# Script para testar a API

API_URL="${1:-http://localhost:3000}"
API_STAGE="${2:-dev}"

echo "🧪 Testando API Hackaton Platform"
echo "API URL: $API_URL"
echo ""

# Cores
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Função para fazer requisição
test_endpoint() {
    local method=$1
    local endpoint=$2
    local body=$3
    local expected_status=$4
    
    echo -e "${YELLOW}Testing${NC} $method $endpoint"
    
    if [ -z "$body" ]; then
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$API_URL$endpoint")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "$API_URL$endpoint" \
            -H "Content-Type: application/json" \
            -d "$body")
    fi
    
    status=$(echo "$response" | tail -n1)
    body=$(echo "$response" | head -n-1)
    
    if [ "$status" = "$expected_status" ]; then
        echo -e "${GREEN}✓${NC} Status: $status"
        echo "$body" | jq . 2>/dev/null || echo "$body"
    else
        echo -e "${RED}✗${NC} Status: $status (esperado: $expected_status)"
        echo "$body"
    fi
    echo ""
}

# Testes
echo "--- CRUD Tests ---"
echo ""

# Criar documento
DOC_BODY='{"title":"Documento de Teste","content":"Este é um documento de teste para validar a API"}'
test_endpoint "POST" "/$API_STAGE/documents" "$DOC_BODY" "201"

# Listar documentos
test_endpoint "GET" "/$API_STAGE/documents" "" "200"

# Obter documento (usar ID da resposta anterior)
DOC_ID="test-doc-123"
test_endpoint "GET" "/$API_STAGE/documents/$DOC_ID" "" "404"

# Atualizar documento
UPDATE_BODY='{"title":"Documento Atualizado","content":"Conteúdo atualizado"}'
test_endpoint "PUT" "/$API_STAGE/documents/$DOC_ID" "$UPDATE_BODY" "404"

# Deletar documento
test_endpoint "DELETE" "/$API_STAGE/documents/$DOC_ID" "" "404"

echo ""
echo "--- Arquivo Tests ---"
echo ""

# Gerar PDF
PDF_BODY='{"title":"Relatório","content":"Este é um relatório em PDF"}'
test_endpoint "POST" "/$API_STAGE/pdf" "$PDF_BODY" "201"

# Upload de arquivo
UPLOAD_BODY='{"document_id":"doc-123","file_name":"teste.txt","content":"Conteúdo do arquivo"}'
test_endpoint "POST" "/$API_STAGE/upload" "$UPLOAD_BODY" "201"

echo ""
echo -e "${GREEN}✅ Testes concluídos!${NC}"
