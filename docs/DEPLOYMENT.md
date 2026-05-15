# Guia de Deployment

## 1. Preparar Ambiente AWS

```bash
# Criar bucket para state do Terraform
aws s3 mb s3://hackaton-terraform-state --region us-east-1

# Criar tabela DynamoDB para locks
aws dynamodb create-table \
  --table-name terraform-locks \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region us-east-1
```

## 2. Deploy da Infraestrutura

```bash
cd terraform

# Inicializar Terraform
terraform init

# Verificar plano
terraform plan -out=tfplan

# Aplicar configuração
terraform apply tfplan

# Capturar outputs
terraform output -json > ../outputs.json
```

## 3. Preparar Backend (Lambda)

```bash
cd ../src

# Instalar dependências
pip install -r requirements.txt

# Criar estrutura de diretórios
mkdir -p dist

# Copiar código fonte
cp -r * dist/ 2>/dev/null || true

# Criar ZIP para Lambda
cd dist
zip -r ../lambda_code.zip .
cd ..

# Copiar para módulo API
cp lambda_code.zip ../terraform/modules/api/
```

## 4. Deploy do Frontend

```bash
cd ../frontend

# Instalar dependências
npm install --legacy-peer-deps

# Capturar variáveis de ambiente
export REACT_APP_API_URL=<API_ENDPOINT_DO_TERRAFORM>

# Build
npm run build

# Deploy para S3
aws s3 sync build/ s3://<FRONTEND_BUCKET>/ --delete

# Invalidar CloudFront
aws cloudfront create-invalidation \
  --distribution-id <DISTRIBUTION_ID> \
  --paths "/*"
```

## 5. Verificação Pós-Deploy

```bash
# Testar API
curl https://<API_ENDPOINT>/api/documents

# Acessar Frontend
https://<CLOUDFRONT_DOMAIN>

# Verificar Logs
aws logs tail /aws/apigateway/hackaton-platform --follow
aws logs tail /aws/lambda/hackaton-platform-crud-handler --follow
```

## 6. Cleanup (Opcional)

```bash
# Remover infraestrutura
cd terraform
terraform destroy

# Limpar buckets
aws s3 rb s3://hackaton-terraform-state --force
```

## Troubleshooting

### Lambda não consegue acessar DynamoDB
- Verificar IAM policy no módulo `iam/main.tf`
- Validar nome da tabela em `terraform.tfvars`

### CloudFront retorna 403
- Verificar bucket policy em `modules/cloudfront/main.tf`
- Validar Origin Access Identity

### CORS errors no frontend
- Verificar CORS configuration em `modules/s3/main.tf`
- Validar headers na API Gateway

### Timeout em Lambda
- Aumentar timeout em `modules/api/variables.tf`
- Verificar logs no CloudWatch

## Monitoramento

```bash
# Visualizar métricas Lambda
aws cloudwatch get-metric-statistics \
  --namespace AWS/Lambda \
  --metric-name Duration \
  --start-time 2024-01-01T00:00:00Z \
  --end-time 2024-01-02T00:00:00Z \
  --period 300 \
  --statistics Average \
  --dimensions Name=FunctionName,Value=hackaton-platform-crud-handler
```
