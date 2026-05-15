# 🔌 API Endpoints Reference

## Base URL
```
https://{API_ENDPOINT}/{STAGE}
```

Exemplo: `https://abc123.execute-api.us-east-1.amazonaws.com/dev`

---

## 📄 Documentos

### POST /documents
Criar novo documento
```bash
curl -X POST https://api.example.com/dev/documents \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Título",
    "content": "Conteúdo..."
  }'
```
**Status**: 201 Created

---

### GET /documents
Listar documentos (paginado)
```bash
curl https://api.example.com/dev/documents?limit=10&offset=0
```
**Parâmetros**:
- `limit` (optional): Máximo de resultados (default: 10, max: 100)
- `offset` (optional): Número de registros a pular (default: 0)

**Status**: 200 OK

---

### GET /documents/{documentId}
Obter um documento específico
```bash
curl https://api.example.com/dev/documents/uuid-1234
```
**Status**: 200 OK | 404 Not Found

---

### PUT /documents/{documentId}
Atualizar documento
```bash
curl -X PUT https://api.example.com/dev/documents/uuid-1234 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Novo Título",
    "content": "Novo conteúdo..."
  }'
```
**Status**: 200 OK | 404 Not Found

---

### DELETE /documents/{documentId}
Deletar documento
```bash
curl -X DELETE https://api.example.com/dev/documents/uuid-1234
```
**Status**: 204 No Content | 404 Not Found

---

## 📁 Arquivos

### POST /pdf
Gerar PDF a partir de documento
```bash
curl -X POST https://api.example.com/dev/pdf \
  -H "Content-Type: application/json" \
  -d '{
    "document_id": "uuid-1234",
    "title": "Relatório",
    "content": "Conteúdo do PDF..."
  }'
```
**Status**: 201 Created

---

### POST /upload
Fazer upload de arquivo
```bash
curl -X POST https://api.example.com/dev/upload \
  -H "Content-Type: application/json" \
  -d '{
    "document_id": "uuid-1234",
    "file_name": "documento.pdf",
    "content": "base64-encoded-content"
  }'
```
**Status**: 201 Created

---

## 📊 Respostas

### Sucesso
```json
{
  "documentId": "uuid-1234",
  "title": "Título",
  "content": "Conteúdo",
  "userId": "anonymous",
  "createdAt": "2024-01-15T10:30:00",
  "updatedAt": "2024-01-15T10:30:00",
  "status": "active"
}
```

### Lista
```json
{
  "items": [...],
  "count": 1,
  "limit": 10,
  "offset": 0
}
```

### Erro
```json
{
  "error": "Descrição do erro"
}
```

---

## 🔑 Status HTTP

| Código | Significado |
|--------|------------|
| 200 | OK |
| 201 | Created |
| 204 | No Content |
| 400 | Bad Request |
| 404 | Not Found |
| 500 | Server Error |

---

## 📝 Request Headers

```
Content-Type: application/json
Access-Control-Allow-Origin: *
```

---

## 🔒 Autenticação

Atualmente usa `user_id = "anonymous"`.

Para produção, adicionar:
- Cognito
- API Key
- OAuth 2.0

---

## ⚡ Rate Limiting

- **Limite**: 100 requisições por segundo
- **Burst**: 200 requisições

---

## 🧪 Testar com Postman

1. Importar: `Hackaton_Platform_API.postman_collection.json`
2. Definir variável `api_url`
3. Executar requests

---

## 🧪 Testar com cURL

```bash
# Listar
curl https://api.example.com/dev/documents

# Criar
curl -X POST https://api.example.com/dev/documents \
  -H "Content-Type: application/json" \
  -d '{"title":"Doc","content":"Conteúdo"}'

# Obter
curl https://api.example.com/dev/documents/{id}

# Atualizar
curl -X PUT https://api.example.com/dev/documents/{id} \
  -H "Content-Type: application/json" \
  -d '{"title":"Novo","content":"Novo"}'

# Deletar
curl -X DELETE https://api.example.com/dev/documents/{id}

# PDF
curl -X POST https://api.example.com/dev/pdf \
  -H "Content-Type: application/json" \
  -d '{"document_id":"id","title":"Rel","content":"Cont"}'

# Upload
curl -X POST https://api.example.com/dev/upload \
  -H "Content-Type: application/json" \
  -d '{"document_id":"id","file_name":"f.txt","content":"abc"}'
```

---

## 📚 Documentação Completa

Ver [docs/API.md](docs/API.md) para detalhes completos.
