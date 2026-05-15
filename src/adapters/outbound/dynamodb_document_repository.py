import json
import boto3
import os
from datetime import datetime
from typing import Optional, List
from src.domain.document import Document
from src.ports.document_repository import DocumentRepository


class DynamoDBDocumentRepository(DocumentRepository):
    """Implementação do repositório de documentos usando DynamoDB"""
    
    def __init__(self):
        self.dynamodb = boto3.resource('dynamodb')
        self.table_name = os.environ.get('DYNAMODB_TABLE_NAME', 'hackaton-documents')
        self.table = self.dynamodb.Table(self.table_name)
    
    async def save(self, document: Document) -> Document:
        """Salvar documento no DynamoDB"""
        try:
            self.table.put_item(Item=self._to_dynamodb_item(document))
            return document
        except Exception as e:
            print(f"Erro ao salvar documento: {e}")
            raise
    
    async def get_by_id(self, document_id: str) -> Optional[Document]:
        """Obter documento pelo ID"""
        try:
            response = self.table.get_item(Key={'documentId': document_id})
            if 'Item' in response:
                return self._from_dynamodb_item(response['Item'])
            return None
        except Exception as e:
            print(f"Erro ao obter documento: {e}")
            raise
    
    async def list_by_user(self, user_id: str, limit: int = 10, offset: int = 0) -> List[Document]:
        """Listar documentos por usuário"""
        try:
            response = self.table.query(
                IndexName='UserIdIndex',
                KeyConditionExpression='userId = :user_id',
                ExpressionAttributeValues={':user_id': user_id},
                Limit=limit,
                ExclusiveStartKey={'userId': user_id, 'timestamp': offset} if offset else None
            )
            
            documents = [self._from_dynamodb_item(item) for item in response.get('Items', [])]
            return documents
        except Exception as e:
            print(f"Erro ao listar documentos: {e}")
            raise
    
    async def update(self, document: Document) -> Document:
        """Atualizar documento"""
        try:
            self.table.put_item(Item=self._to_dynamodb_item(document))
            return document
        except Exception as e:
            print(f"Erro ao atualizar documento: {e}")
            raise
    
    async def delete(self, document_id: str) -> bool:
        """Deletar documento"""
        try:
            self.table.delete_item(Key={'documentId': document_id})
            return True
        except Exception as e:
            print(f"Erro ao deletar documento: {e}")
            raise
    
    def _to_dynamodb_item(self, document: Document) -> dict:
        """Converter Document para item do DynamoDB"""
        return {
            'documentId': document.document_id,
            'title': document.title,
            'content': document.content,
            'userId': document.user_id,
            'createdAt': int(document.created_at.timestamp()),
            'updatedAt': int(document.updated_at.timestamp()),
            'timestamp': int(document.updated_at.timestamp()),
            'filePath': document.file_path or '',
            'status': document.status
        }
    
    def _from_dynamodb_item(self, item: dict) -> Document:
        """Converter item do DynamoDB para Document"""
        return Document(
            document_id=item.get('documentId'),
            title=item.get('title'),
            content=item.get('content'),
            user_id=item.get('userId'),
            created_at=datetime.fromtimestamp(float(item.get('createdAt', 0))),
            updated_at=datetime.fromtimestamp(float(item.get('updatedAt', 0))),
            file_path=item.get('filePath') or None,
            status=item.get('status', 'active')
        )
