# API Documentation

## Base URL

```
https://{API_ENDPOINT}/{STAGE}
```

## Autenticação

Atualmente, a API usa `user_id = "anonymous"` para desenvolvimento. Em produção, será necessário implementar:
- Amazon Cognito
- AWS API Key
- OAuth 2.0

## Endpoints

### Documentos

#### 1. Criar Documento
```http
POST /documents
Content-Type: application/json

{
  "title": "Título do Documento",
  "content": "Conteúdo do documento..."
}
```

**Resposta (201):**
```json
{
  "documentId": "uuid-1234",
  "title": "Título do Documento",
  "content": "Conteúdo do documento...",
  "userId": "anonymous",
  "createdAt": "2024-01-15T10:30:00",
  "updatedAt": "2024-01-15T10:30:00",
  "status": "active"
}
```

#### 2. Listar Documentos
```http
GET /documents?limit=10&offset=0
```

**Resposta (200):**
```json
{
  "items": [
    {
      "documentId": "uuid-1234",
      "title": "Documento 1",
      "content": "...",
      "userId": "anonymous",
      "createdAt": "2024-01-15T10:30:00",
      "updatedAt": "2024-01-15T10:30:00",
      "status": "active"
    }
  ],
  "count": 1,
  "limit": 10,
  "offset": 0
}
```

#### 3. Obter Documento por ID
```http
GET /documents/{documentId}
```

**Resposta (200):**
```json
{
  "documentId": "uuid-1234",
  "title": "Documento 1",
  "content": "Conteúdo...",
  "userId": "anonymous",
  "createdAt": "2024-01-15T10:30:00",
  "updatedAt": "2024-01-15T10:30:00",
  "status": "active"
}
```

#### 4. Atualizar Documento
```http
PUT /documents/{documentId}
Content-Type: application/json

{
  "title": "Novo Título",
  "content": "Novo conteúdo..."
}
```

**Resposta (200):**
```json
{
  "documentId": "uuid-1234",
  "title": "Novo Título",
  "content": "Novo conteúdo...",
  "userId": "anonymous",
  "createdAt": "2024-01-15T10:30:00",
  "updatedAt": "2024-01-15T11:00:00",
  "status": "active"
}
```

#### 5. Deletar Documento
```http
DELETE /documents/{documentId}
```

**Resposta (204):** Sem conteúdo

### Arquivos e PDFs

#### 1. Gerar PDF
```http
POST /pdf
Content-Type: application/json

{
  "document_id": "uuid-1234",
  "title": "Relatório Mensal",
  "content": "Conteúdo do PDF..."
}
```

**Resposta (201):**
```json
{
  "fileId": "file-uuid-5678",
  "documentId": "uuid-1234",
  "bucketName": "hackaton-uploads-123456",
  "s3Key": "documents/uuid-1234/exports/file-uuid-5678.pdf",
  "fileType": "pdf",
  "fileSize": 15234,
  "uploadedAt": "2024-01-15T10:30:00",
  "url": "s3://hackaton-uploads-123456/documents/uuid-1234/exports/file-uuid-5678.pdf"
}
```

#### 2. Upload de Arquivo
```http
POST /upload
Content-Type: application/json

{
  "document_id": "uuid-1234",
  "file_name": "documento.docx",
  "content": "base64-encoded-content-here"
}
```

**Resposta (201):**
```json
{
  "fileId": "file-uuid-9012",
  "documentId": "uuid-1234",
  "bucketName": "hackaton-uploads-123456",
  "s3Key": "documents/uuid-1234/attachments/documento.docx",
  "fileType": "docx",
  "fileSize": 45678,
  "uploadedAt": "2024-01-15T10:30:00",
  "url": "s3://hackaton-uploads-123456/documents/uuid-1234/attachments/documento.docx"
}
```

## Exemplos cURL

### Criar Documento
```bash
curl -X POST https://api.example.com/dev/documents \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Meu Documento",
    "content": "Conteúdo do documento"
  }'
```

### Listar Documentos
```bash
curl https://api.example.com/dev/documents?limit=10
```

### Obter Documento
```bash
curl https://api.example.com/dev/documents/uuid-1234
```

### Atualizar Documento
```bash
curl -X PUT https://api.example.com/dev/documents/uuid-1234 \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Título Atualizado",
    "content": "Novo conteúdo"
  }'
```

### Deletar Documento
```bash
curl -X DELETE https://api.example.com/dev/documents/uuid-1234
```

### Gerar PDF
```bash
curl -X POST https://api.example.com/dev/pdf \
  -H "Content-Type: application/json" \
  -d '{
    "document_id": "uuid-1234",
    "title": "Relatório",
    "content": "Conteúdo do relatório"
  }'
```

### Upload de Arquivo
```bash
curl -X POST https://api.example.com/dev/upload \
  -H "Content-Type: application/json" \
  -d '{
    "document_id": "uuid-1234",
    "file_name": "anexo.pdf",
    "content": "base64-encoded-content"
  }'
```

## Códigos de Status

| Código | Significado |
|--------|------------|
| 200 | OK - Requisição bem-sucedida |
| 201 | Created - Recurso criado com sucesso |
| 204 | No Content - Requisição bem-sucedida (sem conteúdo) |
| 400 | Bad Request - Requisição inválida |
| 404 | Not Found - Recurso não encontrado |
| 500 | Internal Server Error - Erro no servidor |

## Tratamento de Erros

Todas as respostas de erro seguem o formato:

```json
{
  "error": "Descrição do erro",
  "message": "Detalhes adicionais (opcional)"
}
```

## CORS

A API permite requisições de qualquer origem:

```
Access-Control-Allow-Origin: *
Access-Control-Allow-Methods: GET, POST, PUT, DELETE, OPTIONS
Access-Control-Allow-Headers: Content-Type, Authorization
```

## Rate Limiting

- **Limite padrão**: 100 requisições por segundo
- **Burst**: 200 requisições

## Paginação

Use os parâmetros `limit` e `offset` para paginar resultados:

```http
GET /documents?limit=20&offset=40
```

## Validação de Entrada

### Título do Documento
- Obrigatório
- Máximo 255 caracteres
- Não pode ser vazio

### Conteúdo do Documento
- Obrigatório
- Sem limite de caracteres
- Suporta formatação básica

### Nome do Arquivo
- Obrigatório
- Máximo 255 caracteres
- Caracteres válidos: a-z, A-Z, 0-9, `-`, `_`, `.`

## Boas Práticas

1. **Use IDs de documentos válidos** - Os IDs são UUIDs
2. **Valide dados no cliente** - Reduza requisições inválidas
3. **Implemente retry logic** - Para erros 5xx temporários
4. **Use paginação** - Para grandes volumes de dados
5. **Cache responses** - Melhore performance do cliente
6. **Monitore rate limits** - Implemente throttling
