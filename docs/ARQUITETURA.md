# Arquitetura Hexagonal Explicada

## O que é Arquitetura Hexagonal?

A Arquitetura Hexagonal (também conhecida como "Ports and Adapters") é um padrão arquitetural que desacopla a lógica de negócio das dependências externas.

## Estrutura

```
        ┌─────────────────────────────────────────────────┐
        │           CAMADA DE APRESENTAÇÃO               │
        │  (Controllers, HTTP Handlers, REST Endpoints)  │
        └──────────────┬──────────────────────────────────┘
                       │
        ┌──────────────┴──────────────────────────────────┐
        │           CAMADA DE APLICAÇÃO                   │
        │   (Use Cases, Orquestração de Negócio)         │
        └──────────────┬──────────────────────────────────┘
                       │
        ┌──────────────┴──────────────────────────────────┐
        │           CAMADA DE DOMÍNIO                     │
        │  (Entidades, Lógica Pura, Sem Dependências)   │
        └──────────────┬──────────────────────────────────┘
                       │
        ┌──────────────┴──────────────────────────────────┐
        │        CAMADA DE INFRAESTRUTURA                 │
        │  (BD, APIs Externas, Serviços)                 │
        └─────────────────────────────────────────────────┘
```

## Componentes

### 1. Domain (Domínio)
- Entidades: `Document`, `File`
- Lógica pura, independente de frameworks
- Sem dependências externas

```python
@dataclass
class Document:
    document_id: str
    title: str
    content: str
    user_id: str
    created_at: datetime
```

### 2. Ports (Portas/Interfaces)
- Definem contratos abstratos
- Independem da implementação
- Exemplo: `DocumentRepository`, `FileStorage`

```python
class DocumentRepository(ABC):
    @abstractmethod
    async def save(self, document: Document):
        pass
```

### 3. Adapters (Adaptadores)
- Implementações concretas das portas
- Conectam o sistema a recursos externos

#### Adapters de Entrada (Inbound)
- Controllers HTTP
- Transformam requisições HTTP em casos de uso

#### Adapters de Saída (Outbound)
- Implementações de repositórios
- Integrações com DynamoDB, S3, APIs

### 4. Application (Aplicação)
- Casos de uso (Use Cases)
- Orquestram lógica de negócio
- Usam portas, não implementações concretas

```python
class CreateDocumentUseCase:
    def __init__(self, document_repo: DocumentRepository):
        self.document_repo = document_repo
    
    async def execute(self, title, content, user_id):
        document = Document(...)
        return await self.document_repo.save(document)
```

## Fluxo de Requisição

1. **HTTP Request** → Controller (Adapter de Entrada)
2. **Controller** → Use Case (Aplicação)
3. **Use Case** → Domain (Lógica)
4. **Domain** → Repository Port (Interface)
5. **Repository** → DynamoDB Adapter (Saída)

## Benefícios

✅ **Testabilidade**: Fácil criar mocks das portas
✅ **Manutenibilidade**: Código organizado em camadas
✅ **Flexibilidade**: Trocar implementações sem afetar lógica
✅ **Independência**: Lógica não depende de frameworks
✅ **Escalabilidade**: Fácil adicionar novos adapters

## Exemplo Prático

### Testando sem BD Real

```python
class MockDocumentRepository(DocumentRepository):
    async def save(self, document):
        return document
    
    async def get_by_id(self, id):
        return Document(...)

# Usar mock no teste
use_case = CreateDocumentUseCase(MockDocumentRepository())
result = await use_case.execute("Título", "Conteúdo", "user1")
```

## Inversão de Dependência

```
❌ Errado (Acoplamento):
UseCase → DynamoDBRepository → boto3

✅ Certo (Desacoplado):
UseCase → DocumentRepository (Interface)
         ↓
    DynamoDBRepository (Implementação)
```

## Estrutura de Diretórios

```
src/
├── domain/              # Entidades puras
│   ├── document.py
│   └── file.py
├── ports/               # Interfaces abstratas
│   ├── document_repository.py
│   ├── file_storage.py
│   └── pdf_generator.py
├── application/         # Casos de uso
│   ├── document_usecases.py
│   └── file_usecases.py
└── adapters/
    ├── inbound/         # Controllers HTTP
    │   └── controllers.py
    └── outbound/        # Implementações
        ├── dynamodb_document_repository.py
        ├── s3_file_storage.py
        └── reportlab_pdf_generator.py
```

## Adicionando Nova Funcionalidade

1. **Criar entidade no Domain**
2. **Definir porta (interface)**
3. **Implementar adapter**
4. **Criar use case**
5. **Criar controller**

Isso garante que a lógica fica centralizada e testável!
