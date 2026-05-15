# 📋 Checklist de Deployment

Use este checklist para garantir que tudo está configurado corretamente antes de deployar em produção.

## ✅ Pré-requisitos

- [ ] AWS Account criada e ativa
- [ ] AWS CLI instalado e configurado (`aws configure`)
- [ ] Terraform >= 1.0 instalado
- [ ] Python 3.9+ instalado
- [ ] Node.js 16+ instalado
- [ ] Git configurado

## ✅ Fase 1: Preparação

### Variáveis e Configuração
- [ ] Copiar `terraform/terraform.tfvars.example` para `terraform/terraform.tfvars`
- [ ] Editar `terraform/terraform.tfvars` com valores corretos
- [ ] Validar valores: `project_name`, `environment`, `aws_region`
- [ ] Copiar `.env.example` para `.env` e configurar

### Credenciais AWS
- [ ] AWS Access Key ID configurado
- [ ] AWS Secret Access Key configurado
- [ ] Permissões de admin ou suficientes
- [ ] Testar conexão: `aws sts get-caller-identity`

### Preparar Estado do Terraform
- [ ] Criar bucket S3 para terraform state: `aws s3 mb s3://seu-terraform-state`
- [ ] Criar tabela DynamoDB para locks
- [ ] Atualizar `terraform/main.tf` com nome correto do bucket

## ✅ Fase 2: Validação Local

### Backend
- [ ] Instalar dependências: `cd src && pip install -r requirements.txt`
- [ ] Validar sintaxe Python: `python -m py_compile src/lambda_handlers.py`
- [ ] Executar testes: `pytest src/ -v` (se houver testes)

### Frontend
- [ ] Instalar dependências: `cd frontend && npm install`
- [ ] Build local: `npm run build`
- [ ] Verificar se build/ foi criado sem erros

### Terraform
- [ ] Validar sintaxe: `terraform validate`
- [ ] Verificar plano: `terraform plan`
- [ ] Revisar todos os recursos que serão criados
- [ ] Conferir nomes de recursos (evitar conflitos)

## ✅ Fase 3: Deploy da Infraestrutura

### Terraform Apply
- [ ] Executar: `terraform apply`
- [ ] Revisar plano uma última vez
- [ ] Digitar "yes" para confirmar
- [ ] Esperar conclusão (pode levar 5-10 minutos)
- [ ] Anotar outputs importantes:
  - [ ] API Endpoint URL
  - [ ] S3 Bucket Name
  - [ ] DynamoDB Table Name
  - [ ] CloudFront Domain
  - [ ] CloudFront Distribution ID

### Verificação de Recursos
- [ ] API Gateway criada: `aws apigateway get-rest-apis`
- [ ] Lambda functions criadas: `aws lambda list-functions`
- [ ] S3 buckets criados: `aws s3 ls`
- [ ] DynamoDB tables criadas: `aws dynamodb list-tables`
- [ ] CloudFront distributions criadas: `aws cloudfront list-distributions`

## ✅ Fase 4: Deploy do Backend

### Build
- [ ] Executar: `chmod +x build.sh && ./build.sh`
- [ ] Arquivo criado em `dist/lambda_code.zip`
- [ ] Arquivo tem tamanho > 0 bytes

### Upload para Lambda
- [ ] Copiar ZIP: `cp dist/lambda_code.zip terraform/modules/api/`
- [ ] Atualizar Lambda: `terraform apply -target=module.api`
- [ ] Confirmar atualização

### Testes de Lambda
- [ ] Invocar função: `aws lambda invoke --function-name seu-crud-handler output.json`
- [ ] Verificar resposta em `output.json`
- [ ] Checar logs: `aws logs tail /aws/lambda/seu-crud-handler --follow`

## ✅ Fase 5: Deploy do Frontend

### Build
- [ ] Navegar: `cd frontend`
- [ ] Instalar: `npm install`
- [ ] Build: `npm run build`
- [ ] Verificar pasta `build/` existe com arquivos

### Upload para S3
- [ ] Obter bucket name do Terraform output
- [ ] Executar: `aws s3 sync build/ s3://seu-bucket/ --delete`
- [ ] Validar upload: `aws s3 ls s3://seu-bucket/`

### CloudFront Invalidation
- [ ] Obter Distribution ID do Terraform output
- [ ] Invalidar cache: `aws cloudfront create-invalidation --distribution-id seu-id --paths "/*"`
- [ ] Aguardar conclusão (~5 minutos)

## ✅ Fase 6: Testes de Integração

### Testes da API
- [ ] Testar endpoint base: `curl seu-api-endpoint/dev/documents`
- [ ] Criar documento: Testar POST `/documents`
- [ ] Listar documentos: Testar GET `/documents`
- [ ] Obter documento: Testar GET `/documents/{id}`
- [ ] Atualizar: Testar PUT `/documents/{id}`
- [ ] Deletar: Testar DELETE `/documents/{id}`
- [ ] Gerar PDF: Testar POST `/pdf`
- [ ] Upload: Testar POST `/upload`

### Testes do Frontend
- [ ] Abrir URL CloudFront no navegador
- [ ] Página carrega sem erros (verificar console)
- [ ] Criar novo documento
- [ ] Listar documentos
- [ ] Atualizar documento
- [ ] Deletar documento
- [ ] Gerar PDF
- [ ] Validar CORS (abrir DevTools > Network)

### Testes de Dados
- [ ] Dados salvos em DynamoDB: `aws dynamodb scan --table-name sua-tabela`
- [ ] Arquivos em S3: `aws s3 ls s3://seu-bucket/`
- [ ] CloudWatch Logs existem: `aws logs describe-log-groups`

## ✅ Fase 7: Monitoramento e Segurança

### Logging
- [ ] CloudWatch Logs habilitado para API Gateway
- [ ] CloudWatch Logs habilitado para Lambda
- [ ] X-Ray tracing ativado (opcional)

### Segurança
- [ ] S3 buckets com bloqueio de acesso público
- [ ] DynamoDB com encryption habilitado
- [ ] IAM roles com permissões mínimas
- [ ] API Gateway com CORS configurado corretamente
- [ ] CloudFront com HTTPS obrigatório

### Backups
- [ ] DynamoDB Point-in-Time Recovery ativado
- [ ] S3 Versioning ativado
- [ ] Backup plan documentado

## ✅ Fase 8: Otimização e Custos

### Performance
- [ ] Lambda memory adequado (512MB recomendado)
- [ ] Lambda timeout apropriado (30-60s)
- [ ] CloudFront cache configurado
- [ ] DynamoDB billing mode apropriado

### Custos
- [ ] Revisar AWS Free Tier limits
- [ ] Monitorar custos estimados
- [ ] Configurar Cost Alerts
- [ ] Documento de estimativa de custos criado

## ✅ Fase 9: Pós-Deployment

### Documentação
- [ ] README.md atualizado com URLs reais
- [ ] Endpoints documentados
- [ ] Credenciais seguras e não no repo
- [ ] Runbook de operação criado

### Handoff
- [ ] Time informado sobre deployment
- [ ] Acesso concedido para o ambiente
- [ ] Documentação compartilhada
- [ ] Suporte definido

## ⚠️ Possíveis Problemas e Soluções

### Lambda não consegue acessar DynamoDB
**Solução**: Verificar IAM role policy
```bash
aws iam get-role-policy --role-name seu-role --policy-name seu-policy
```

### CORS errors no frontend
**Solução**: Verificar configuração CORS em S3 e API Gateway
```bash
aws s3api get-bucket-cors --bucket seu-bucket
```

### CloudFront mostra 403
**Solução**: Verificar Origin Access Identity
```bash
aws cloudfront get-distribution --id seu-id | grep OriginAccessIdentity
```

### Custos altos
**Solução**: Revisar DynamoDB e Lambda settings
- Usar DynamoDB on-demand para desenvolvimento
- Aumentar Lambda timeout para evitar retentativas
- Habilitar CloudFront caching

## 📊 Checklist de Segurança

- [ ] Senhas e tokens não estão no código
- [ ] `.env` não é commitado
- [ ] Terraform state está encriptado
- [ ] Logs contêm informações sensíveis mascaradas
- [ ] Acesso IAM é baseado em princípio de menor privilégio
- [ ] VPC segurança configurada (se necessário)
- [ ] WAF configurado (se necessário)

## 🎉 Pós-Deployment

- [ ] Todos os testes passando
- [ ] Documentação atualizada
- [ ] Time comunicado
- [ ] Monitoramento ativo
- [ ] Alertas configurados
- [ ] Plano de disaster recovery documentado
- [ ] Rotina de backup estabelecida

---

**Data do Deployment**: _______________

**Responsável**: _______________

**Observações**: 

_______________________________________________________________

_______________________________________________________________

_______________________________________________________________
