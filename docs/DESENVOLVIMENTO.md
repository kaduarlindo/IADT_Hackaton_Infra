# Guia de Desenvolvimento

## Configuração do Ambiente Local

### 1. Python Backend

```bash
# Criar ambiente virtual
python -m venv venv

# Ativar ambiente
# Windows:
venv\Scripts\activate
# macOS/Linux:
source venv/bin/activate

# Instalar dependências
pip install -r src/requirements-dev.txt
```

### 2. Node.js Frontend

```bash
cd frontend

# Instalar dependências
npm install

# Iniciar desenvolvimento
npm start
```

## Executar Testes

```bash
# Backend tests
cd src
pytest -v --cov=.

# Frontend tests
cd frontend
npm test
```

## Estrutura de Código

### Domain Layer

Objetos de domínio imutáveis:

```python
@dataclass
class Document:
    document_id: str
    title: str
    content: str
    # ... sem métodos de persistência
```

### Ports Layer

Abstrações com type hints:

```python
class DocumentRepository(ABC):
    @abstractmethod
    async def save(self, document: Document) -> Document:
        """Salvar documento"""
```

### Use Cases

Lógica de negócio pura:

```python
class CreateDocumentUseCase:
    def __init__(self, repo: DocumentRepository):
        self.repo = repo
    
    async def execute(self, title: str, content: str):
        doc = Document(...)
        return await self.repo.save(doc)
```

### Adapters

Implementações concretas:

```python
class DynamoDBDocumentRepository(DocumentRepository):
    async def save(self, document: Document) -> Document:
        # Lógica de persistência específica do DynamoDB
```

## Padrões

### Async/Await

Todo acesso a recurso externo é assíncrono:

```python
async def handle_create(self, event):
    document = await self.create_usecase.execute(...)
    return response
```

### Error Handling

```python
try:
    result = await use_case.execute(...)
except ValueError as e:
    return {'statusCode': 400, 'body': json.dumps({'error': str(e)})}
except Exception as e:
    return {'statusCode': 500, 'body': json.dumps({'error': str(e)})}
```

### Logging

```python
import logging
logger = logging.getLogger(__name__)

logger.info(f"Criando documento: {title}")
logger.error(f"Erro ao salvar: {e}")
```

## Adicionar Nova Entidade

### 1. Domain
```python
# src/domain/new_entity.py
@dataclass
class NewEntity:
    id: str
    name: str
```

### 2. Port
```python
# src/ports/new_entity_repository.py
class NewEntityRepository(ABC):
    @abstractmethod
    async def save(self, entity: NewEntity):
        pass
```

### 3. Adapter
```python
# src/adapters/outbound/dynamodb_new_entity_repository.py
class DynamoDBNewEntityRepository(NewEntityRepository):
    async def save(self, entity: NewEntity):
        # Implementação
        pass
```

### 4. Use Case
```python
# src/application/new_entity_usecases.py
class CreateNewEntityUseCase:
    def __init__(self, repo: NewEntityRepository):
        self.repo = repo
    
    async def execute(self, name: str):
        entity = NewEntity(...)
        return await self.repo.save(entity)
```

### 5. Controller
```python
# src/adapters/inbound/controllers.py
async def handle_create_new_entity(self, event):
    # Lógica do controller
    pass
```

## Ambiente Local (SAM/LocalStack)

```bash
# Iniciar LocalStack (AWS local)
docker-compose up -d

# Deploy local com SAM
sam local start-api

# Testar
curl http://localhost:3000/api/documents
```

## Deploy em Dev

```bash
cd terraform

# Usar workspace de dev
terraform workspace new dev
terraform workspace select dev

# Aplicar com variáveis de dev
terraform apply -var-file="dev.tfvars"
```

## Debugging

### CloudWatch Logs

```bash
aws logs tail /aws/lambda/hackaton-platform-crud-handler --follow

# Com grep
aws logs tail /aws/lambda/hackaton-platform-crud-handler --follow | grep "ERROR"
```

### X-Ray

```bash
aws xray get-service-graph
aws xray batch-get-traces --trace-ids <trace-id>
```

### Teste Local de Lambda

```bash
# Invocar local
sam local invoke CRUDHandler -e events/create.json

# Com debug
sam local invoke CRUDHandler -d 5858 -e events/create.json
```

## Lint e Formatação

```bash
# Black (formatação Python)
black src/

# Flake8 (linting)
flake8 src/

# MyPy (type checking)
mypy src/
```

## Git Workflow

```bash
# Feature branch
git checkout -b feature/document-versioning

# Commit pequenos e descritivos
git commit -m "feat: adicionar versionamento de documentos"

# Push e PR
git push origin feature/document-versioning
```

## Performance

### Caching
```python
# Usar cache para queries frequentes
@cache
async def get_document_metadata(self, doc_id):
    return await self.repo.get(doc_id)
```

### Batch Operations
```python
# DynamoDB batch
response = await dynamodb.batch_get_item(RequestItems={...})
```

### Connection Pooling
```python
# Reusar conexões
s3_client = boto3.client('s3')
dynamodb = boto3.resource('dynamodb')
```

## Segurança

### Validação de Input
```python
def validate_title(title: str) -> bool:
    if not title or len(title) > 255:
        raise ValueError("Título inválido")
    return True
```

### Sanitização
```python
from html import escape
safe_content = escape(content)
```

### Autenticação
```python
user_id = event.get('requestContext', {}).get('authorizer', {}).get('claims', {}).get('sub')
```
