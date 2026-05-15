# 🚀 Quick Start - Hackaton Platform

## 1️⃣ Desenvolvimento Local (Com Docker)

### Pré-requisitos
- Docker e Docker Compose instalados
- AWS CLI (opcional, para testes manuais)
- Bash/Shell

### Iniciar
```bash
# Dar permissão ao script
chmod +x start-dev.sh

# Iniciar todos os serviços
./start-dev.sh
```

### Acessar
- **Frontend**: http://localhost:3001
- **Backend API**: http://localhost:3000
- **MinIO (S3)**: http://localhost:9001 (minioadmin/minioadmin)
- **DynamoDB**: http://localhost:8000

### Parar
```bash
docker-compose down
```

## 2️⃣ Deploy no AWS

### Pré-requisitos
- AWS CLI configurado com credenciais
- Terraform >= 1.0
- Python 3.9+
- Node.js 16+

### Passo 1: Preparar Variáveis
```bash
cd terraform

# Editar terraform.tfvars
vim terraform.tfvars

# Exemplo:
# aws_region   = "us-east-1"
# project_name = "meu-hackaton"
# environment  = "dev"
```

### Passo 2: Deploy da Infraestrutura
```bash
# Inicializar Terraform
terraform init

# Verificar plano
terraform plan

# Aplicar
terraform apply

# Anotar outputs (API endpoint, CloudFront domain, etc)
terraform output
```

### Passo 3: Build do Backend
```bash
cd ..

# Dar permissão
chmod +x build.sh

# Build
./build.sh

# Arquivos criados em dist/lambda_code.zip
```

### Passo 4: Deploy do Backend (Lambda)
```bash
cd terraform

# Copiar ZIP para módulo API
cp ../dist/lambda_code.zip modules/api/

# Atualizar Lambda
terraform apply -target=module.api

# Obter endpoint da API
terraform output api_endpoint
```

### Passo 5: Deploy do Frontend
```bash
cd ../frontend

# Instalar dependências
npm install

# Definir API URL (do passo anterior)
export REACT_APP_API_URL=https://seu-api-endpoint/dev

# Build
npm run build

# Deploy para S3 (substituir bucket name)
aws s3 sync build/ s3://seu-bucket-frontend/ --delete

# Invalidar CloudFront
aws cloudfront create-invalidation \
  --distribution-id seu-distribution-id \
  --paths "/*"
```

### Passo 6: Acessar
- **Frontend**: https://seu-cloudfront-domain.cloudfront.net
- **API**: https://seu-api-endpoint/dev

## 3️⃣ Testar a API

### Com cURL
```bash
# Criar documento
curl -X POST https://seu-api-endpoint/dev/documents \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Meu Documento",
    "content": "Conteúdo aqui"
  }'

# Listar
curl https://seu-api-endpoint/dev/documents
```

### Com Postman
1. Importar: `Hackaton_Platform_API.postman_collection.json`
2. Definir variável `api_url`: `https://seu-api-endpoint/dev`
3. Testar endpoints

### Com script
```bash
chmod +x test.sh
./test.sh https://seu-api-endpoint/dev dev
```

## 4️⃣ Estrutura do Projeto

```
.
├── terraform/              # Infraestrutura como código
│   ├── main.tf            # Config principal
│   └── modules/           # Módulos reutilizáveis
│       ├── api/           # Lambda + API Gateway
│       ├── s3/            # Armazenamento
│       ├── dynamodb/      # Banco de dados
│       ├── iam/           # Segurança
│       └── cloudfront/    # CDN
├── src/                   # Backend Python
│   ├── domain/            # Lógica de negócio
│   ├── ports/             # Interfaces
│   ├── application/       # Casos de uso
│   ├── adapters/          # Implementações
│   └── lambda_handlers.py # Entry point Lambda
├── frontend/              # Frontend React
│   ├── public/
│   └── src/
├── docs/                  # Documentação
│   ├── API.md            # Referência API
│   ├── ARQUITETURA.md    # Explicação arquitetura
│   ├── DEPLOYMENT.md     # Guia detalhado deployment
│   └── DESENVOLVIMENTO.md # Guia desenvolvimento
├── docker-compose.yml     # Dev environment
├── build.sh              # Script build backend
├── test.sh              # Script testes
└── Makefile             # Comandos úteis
```

## 5️⃣ Comandos Úteis

### Makefile
```bash
# Ver todos os comandos
make help

# Build completo
make build-backend

# Testes
make test

# Linting
make lint

# Cleanup
make clean

# Deploy tudo
make deploy
```

### Logs
```bash
# Lambda logs
aws logs tail /aws/lambda/hackaton-platform-crud-handler --follow

# API Gateway logs
aws logs tail /aws/apigateway/hackaton-platform --follow

# Local
docker-compose logs -f backend
```

## 6️⃣ Troubleshooting

### Lambda não consegue acessar DynamoDB
```bash
# Verificar IAM policy
aws iam get-role --role-name hackaton-platform-lambda-execution-role

# Verificar variáveis de ambiente
aws lambda get-function-configuration \
  --function-name hackaton-platform-crud-handler
```

### CORS errors no frontend
```bash
# Verificar bucket policy
aws s3api get-bucket-cors --bucket seu-bucket

# Verificar API Gateway CORS
aws apigateway get-stage --rest-api-id seu-api-id --stage-name dev
```

### Custo alto
- Revise o `terraform.tfvars` para ambientes mais baratos
- Use LocalStack para desenvolvimento
- Deletar stacks não usadas: `terraform destroy`

## 7️⃣ Recursos

- [Documentação API](docs/API.md)
- [Arquitetura Hexagonal](docs/ARQUITETURA.md)
- [Deployment Detalhado](docs/DEPLOYMENT.md)
- [Guia Desenvolvimento](docs/DESENVOLVIMENTO.md)
- [README Principal](README.md)

## ❓ Suporte

Para dúvidas ou problemas:
1. Consulte a documentação em `docs/`
2. Verifique os logs em CloudWatch
3. Teste em ambiente local com Docker
4. Valide estrutura com `terraform plan`
