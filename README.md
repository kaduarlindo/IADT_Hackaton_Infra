# Plataforma Hackaton - Arquitetura Hexagonal em Terraform

Uma infraestrutura **pronta para produção** implementada em Terraform para AWS, com arquitetura hexagonal para máxima manutenibilidade e testabilidade.

**Features:**
- ✅ API REST escalável (Lambda + API Gateway)
- ✅ Banco de dados NoSQL (DynamoDB)
- ✅ Upload e armazenamento de arquivos (S3)
- ✅ Geração de PDFs (ReportLab)
- ✅ Frontend moderno (React + CloudFront)
- ✅ Segurança otimizada (IAM, Encryption)
- ✅ Monitoramento incluído (CloudWatch, X-Ray)

**⚡ Quick Start:** [Comece em 5 minutos](QUICKSTART.md)

## 📋 Arquitetura

### Componentes Principais

1. **Frontend (React)**
   - Interface web moderna
   - Gerenciamento de documentos
   - Upload de arquivos
   - Geração de PDF

2. **Backend (Lambda + API Gateway)**
   - Arquitetura hexagonal
   - Operações CRUD em documentos
   - Geração de PDF
   - Upload de arquivos

3. **Armazenamento**
   - **S3**: Armazenamento de arquivos e frontend estático
   - **DynamoDB**: Banco de dados NoSQL para documentos
   - **CloudFront**: CDN para distribuição global

4. **Segurança**
   - IAM Roles e Policies
   - S3 com bloqueio de acesso público
   - X-Ray para tracing

## 🗂️ Estrutura do Projeto

```
.
├── terraform/                    # Infraestrutura como código
│   ├── main.tf                   # Configuração principal
│   ├── variables.tf              # Variáveis
│   ├── terraform.tfvars          # Valores das variáveis
│   └── modules/
│       ├── s3/                   # Módulo S3
│       ├── dynamodb/             # Módulo DynamoDB
│       ├── api/                  # Módulo API Gateway + Lambda
│       ├── iam/                  # Módulo IAM
│       └── cloudfront/           # Módulo CloudFront
├── src/                          # Código backend
│   ├── domain/                   # Entidades de domínio
│   ├── ports/                    # Interfaces (portas)
│   ├── application/              # Casos de uso
│   ├── adapters/
│   │   ├── inbound/              # Controllers (HTTP)
│   │   └── outbound/             # Implementações (DB, S3, etc)
│   └── lambda_handlers.py        # Entry points Lambda
├── frontend/                     # Aplicação React
│   ├── package.json
│   ├── public/
│   └── src/
└── docs/                         # Documentação
```

## 🚀 Como Usar

### Pré-requisitos

- Terraform >= 1.0
- AWS CLI configurado com credenciais
- Node.js >= 16 (para frontend)
- Python 3.9+ (para backend)

### 1. Configurar Variáveis

Edite `terraform/terraform.tfvars`:

```hcl
aws_region   = "us-east-1"
project_name = "seu-projeto"
environment  = "dev"
```

### 2. Deploy da Infraestrutura

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### 3. Deploy do Backend (Lambda)

```bash
# Empacotar código Python
cd ../src
zip -r ../terraform/modules/api/lambda_code.zip .

# Deploy é feito automaticamente pelo Terraform
```

### 4. Deploy do Frontend

```bash
cd ../frontend

# Instalar dependências
npm install

# Build
npm run build

# Deploy para S3
AWS_S3_BUCKET=<bucket-name> npm run deploy
```

## 📐 Arquitetura Hexagonal

### Camadas

1. **Domain** (`src/domain/`)
   - Entidades de negócio
   - Lógica de domínio pura
   - Sem dependências externas

2. **Ports** (`src/ports/`)
   - Interfaces abstratas
   - Definem contratos
   - Independentes de implementação

3. **Application** (`src/application/`)
   - Casos de uso
   - Orquestração de lógica
   - Independentes de frameworks

4. **Adapters** (`src/adapters/`)
   - **Inbound**: Controllers HTTP
   - **Outbound**: Implementações de repositórios e serviços

## 🔌 Portas (Interfaces)

- `DocumentRepository`: Operações em documentos
- `FileStorage`: Armazenamento de arquivos
- `PDFGenerator`: Geração de PDFs

## 🔌 Adapters

- `DynamoDBDocumentRepository`: Implementação em DynamoDB
- `S3FileStorage`: Implementação em S3
- `ReportLabPDFGenerator`: Geração com ReportLab

## 📊 Endpoints da API

### Documentos

- `POST /api/documents` - Criar documento
- `GET /api/documents` - Listar documentos
- `GET /api/documents/{id}` - Obter documento
- `PUT /api/documents/{id}` - Atualizar documento
- `DELETE /api/documents/{id}` - Deletar documento

### Arquivos

- `POST /api/upload` - Fazer upload de arquivo
- `POST /api/pdf` - Gerar PDF

## 🗄️ Modelo de Dados DynamoDB

### Tabela: hackaton-documents

**Chaves:**
- `documentId` (PK)
- `timestamp` (SK)

**Índice Secundário:**
- `UserIdIndex`: `userId` (PK), `timestamp` (SK)

**Atributos:**
- title
- content
- userId
- status
- filePath
- createdAt
- updatedAt

## 🔒 Segurança

- IAM Roles com permissões mínimas
- S3 com bloqueio de acesso público
- Encriptação em repouso (S3, DynamoDB)
- X-Ray para monitoramento distribuído
- CloudWatch Logs para auditoria

## 📈 Monitoramento

- CloudWatch Metrics para Lambda
- DynamoDB throttle alarms
- API Gateway access logs
- X-Ray service map

## 💰 Otimização de Custos

- DynamoDB em modo PAY_PER_REQUEST (desenvolvimento)
- CloudFront para cache de conteúdo estático
- S3 ciclo de vida para limpeza de objetos antigos
- Lambda com timeout apropriado

## 🐛 Troubleshooting

### Erro de permissões Lambda
Verifique as IAM policies no módulo `iam/main.tf`

### DynamoDB throttle
Aumente o capacity mode ou implemente retry logic

### CORS issues
Verifique a configuração CORS em `modules/s3/main.tf`

## 📚 Referências

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Arquitetura Hexagonal](https://en.wikipedia.org/wiki/Hexagonal_architecture)
- [AWS Lambda Best Practices](https://docs.aws.amazon.com/lambda/latest/dg/best-practices.html)

## 📝 Licença

MIT
