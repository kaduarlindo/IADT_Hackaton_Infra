import json
import asyncio
from src.application.document_usecases import (
    CreateDocumentUseCase,
    GetDocumentUseCase,
    ListDocumentsUseCase,
    UpdateDocumentUseCase,
    DeleteDocumentUseCase
)
from src.application.file_usecases import (
    GeneratePDFUseCase,
    UploadFileUseCase
)
from src.adapters.outbound.dynamodb_document_repository import DynamoDBDocumentRepository
from src.adapters.outbound.s3_file_storage import S3FileStorage
from src.adapters.outbound.reportlab_pdf_generator import ReportLabPDFGenerator


class DocumentController:
    """Controller para operações de documento (adapter de entrada)"""
    
    def __init__(self):
        # Instanciar repositórios e adaptadores
        self.doc_repo = DynamoDBDocumentRepository()
        self.file_storage = S3FileStorage()
        self.pdf_generator = ReportLabPDFGenerator()
        
        # Instanciar casos de uso
        self.create_doc_usecase = CreateDocumentUseCase(self.doc_repo, self.file_storage)
        self.get_doc_usecase = GetDocumentUseCase(self.doc_repo)
        self.list_docs_usecase = ListDocumentsUseCase(self.doc_repo)
        self.update_doc_usecase = UpdateDocumentUseCase(self.doc_repo)
        self.delete_doc_usecase = DeleteDocumentUseCase(self.doc_repo, self.file_storage)
        self.generate_pdf_usecase = GeneratePDFUseCase(self.pdf_generator, self.file_storage)
        self.upload_file_usecase = UploadFileUseCase(self.file_storage)
    
    def _cors_headers(self):
        return {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
    
    async def handle_create(self, event: dict) -> dict:
        """Handler para criar documento"""
        try:
            body = json.loads(event.get('body', '{}'))
            user_id = event.get('requestContext', {}).get('authorizer', {}).get('claims', {}).get('sub', 'anonymous')
            
            # Validar entrada
            if not body.get('title') or not body.get('content'):
                return {
                    'statusCode': 400,
                    'body': json.dumps({'error': 'Título e conteúdo são obrigatórios'}),
                    'headers': self._cors_headers()
                }
            
            document = await self.create_doc_usecase.execute(
                title=body.get('title'),
                content=body.get('content'),
                user_id=user_id
            )
            
            return {
                'statusCode': 201,
                'body': json.dumps(document.to_dict()),
                'headers': self._cors_headers()
            }
        except Exception as e:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': str(e)}),
                'headers': self._cors_headers()
            }
    
    async def handle_get(self, event: dict) -> dict:
        """Handler para obter documento"""
        try:
            document_id = event.get('pathParameters', {}).get('id')
            
            if not document_id:
                return {
                    'statusCode': 400,
                    'body': json.dumps({'error': 'ID do documento é obrigatório'}),
                    'headers': self._cors_headers()
                }
            
            document = await self.get_doc_usecase.execute(document_id)
            
            if not document:
                return {
                    'statusCode': 404,
                    'body': json.dumps({'error': 'Documento não encontrado'}),
                    'headers': self._cors_headers()
                }
            
            return {
                'statusCode': 200,
                'body': json.dumps(document.to_dict()),
                'headers': self._cors_headers()
            }
        except Exception as e:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': str(e)}),
                'headers': self._cors_headers()
            }
    
    async def handle_list(self, event: dict) -> dict:
        """Handler para listar documentos"""
        try:
            user_id = event.get('requestContext', {}).get('authorizer', {}).get('claims', {}).get('sub', 'anonymous')
            query_params = event.get('queryStringParameters', {}) or {}
            
            limit = int(query_params.get('limit', 10))
            offset = int(query_params.get('offset', 0))
            
            # Validar limites
            limit = min(limit, 100)  # Máximo 100 por página
            
            documents = await self.list_docs_usecase.execute(user_id, limit, offset)
            
            return {
                'statusCode': 200,
                'body': json.dumps({
                    'items': [doc.to_dict() for doc in documents],
                    'count': len(documents),
                    'limit': limit,
                    'offset': offset
                }),
                'headers': self._cors_headers()
            }
        except Exception as e:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': str(e)}),
                'headers': self._cors_headers()
            }
    
    async def handle_update(self, event: dict) -> dict:
        """Handler para atualizar documento"""
        try:
            document_id = event.get('pathParameters', {}).get('id')
            
            if not document_id:
                return {
                    'statusCode': 400,
                    'body': json.dumps({'error': 'ID do documento é obrigatório'}),
                    'headers': self._cors_headers()
                }
            
            body = json.loads(event.get('body', '{}'))
            
            document = await self.update_doc_usecase.execute(
                document_id,
                title=body.get('title'),
                content=body.get('content')
            )
            
            if not document:
                return {
                    'statusCode': 404,
                    'body': json.dumps({'error': 'Documento não encontrado'}),
                    'headers': self._cors_headers()
                }
            
            return {
                'statusCode': 200,
                'body': json.dumps(document.to_dict()),
                'headers': self._cors_headers()
            }
        except Exception as e:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': str(e)}),
                'headers': self._cors_headers()
            }
    
    async def handle_delete(self, event: dict) -> dict:
        """Handler para deletar documento"""
        try:
            document_id = event.get('pathParameters', {}).get('id')
            
            if not document_id:
                return {
                    'statusCode': 400,
                    'body': json.dumps({'error': 'ID do documento é obrigatório'}),
                    'headers': self._cors_headers()
                }
            
            result = await self.delete_doc_usecase.execute(document_id)
            
            if not result:
                return {
                    'statusCode': 404,
                    'body': json.dumps({'error': 'Documento não encontrado'}),
                    'headers': self._cors_headers()
                }
            
            return {
                'statusCode': 204,
                'body': '',
                'headers': self._cors_headers()
            }
        except Exception as e:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': str(e)}),
                'headers': self._cors_headers()
            }


class FileController:
    """Controller para operações de arquivo (adapter de entrada)"""
    
    def __init__(self):
        self.file_storage = S3FileStorage()
        self.pdf_generator = ReportLabPDFGenerator()
        self.generate_pdf_usecase = GeneratePDFUseCase(self.pdf_generator, self.file_storage)
        self.upload_file_usecase = UploadFileUseCase(self.file_storage)
    
    def _cors_headers(self):
        return {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization'
        }
    
    async def handle_pdf_generation(self, event: dict) -> dict:
        """Handler para gerar PDF"""
        try:
            body = json.loads(event.get('body', '{}'))
            user_id = event.get('requestContext', {}).get('authorizer', {}).get('claims', {}).get('sub', 'anonymous')
            
            # Validar entrada
            if not body.get('title') or not body.get('content'):
                return {
                    'statusCode': 400,
                    'body': json.dumps({'error': 'Título e conteúdo são obrigatórios'}),
                    'headers': self._cors_headers()
                }
            
            file = await self.generate_pdf_usecase.execute(
                document_id=body.get('document_id', 'temp'),
                title=body.get('title'),
                content=body.get('content'),
                user_id=user_id
            )
            
            return {
                'statusCode': 201,
                'body': json.dumps(file.to_dict()),
                'headers': self._cors_headers()
            }
        except Exception as e:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': str(e)}),
                'headers': self._cors_headers()
            }
    
    async def handle_file_upload(self, event: dict) -> dict:
        """Handler para upload de arquivo"""
        try:
            body = json.loads(event.get('body', '{}'))
            user_id = event.get('requestContext', {}).get('authorizer', {}).get('claims', {}).get('sub', 'anonymous')
            
            # Validar entrada
            if not body.get('file_name') or not body.get('content'):
                return {
                    'statusCode': 400,
                    'body': json.dumps({'error': 'Nome e conteúdo do arquivo são obrigatórios'}),
                    'headers': self._cors_headers()
                }
            
            file = await self.upload_file_usecase.execute(
                document_id=body.get('document_id', 'temp'),
                file_name=body.get('file_name'),
                content=body.get('content', '').encode(),
                user_id=user_id
            )
            
            return {
                'statusCode': 201,
                'body': json.dumps(file.to_dict()),
                'headers': self._cors_headers()
            }
        except Exception as e:
            return {
                'statusCode': 400,
                'body': json.dumps({'error': str(e)}),
                'headers': self._cors_headers()
            }
