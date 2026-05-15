import uuid
from datetime import datetime
from typing import List, Optional
from src.domain.document import Document
from src.ports.document_repository import DocumentRepository
from src.ports.file_storage import FileStorage


class CreateDocumentUseCase:
    """Caso de uso para criar documento"""
    
    def __init__(self, document_repo: DocumentRepository, file_storage: FileStorage):
        self.document_repo = document_repo
        self.file_storage = file_storage
    
    async def execute(self, title: str, content: str, user_id: str, file_content: bytes = None) -> Document:
        """Executar criação de documento"""
        document_id = str(uuid.uuid4())
        now = datetime.utcnow()
        
        # Salvar arquivo se fornecido
        file_path = None
        if file_content:
            file = await self.file_storage.upload(
                f"documents/{document_id}/content",
                file_content,
                {"title": title, "user_id": user_id}
            )
            file_path = file.s3_key
        
        # Criar documento
        document = Document(
            document_id=document_id,
            title=title,
            content=content,
            user_id=user_id,
            created_at=now,
            updated_at=now,
            file_path=file_path,
            status="active"
        )
        
        # Salvar no repositório
        return await self.document_repo.save(document)


class GetDocumentUseCase:
    """Caso de uso para obter documento"""
    
    def __init__(self, document_repo: DocumentRepository):
        self.document_repo = document_repo
    
    async def execute(self, document_id: str) -> Optional[Document]:
        """Executar obtenção de documento"""
        return await self.document_repo.get_by_id(document_id)


class ListDocumentsUseCase:
    """Caso de uso para listar documentos"""
    
    def __init__(self, document_repo: DocumentRepository):
        self.document_repo = document_repo
    
    async def execute(self, user_id: str, limit: int = 10, offset: int = 0) -> List[Document]:
        """Executar listagem de documentos"""
        return await self.document_repo.list_by_user(user_id, limit, offset)


class UpdateDocumentUseCase:
    """Caso de uso para atualizar documento"""
    
    def __init__(self, document_repo: DocumentRepository):
        self.document_repo = document_repo
    
    async def execute(self, document_id: str, title: str = None, content: str = None) -> Optional[Document]:
        """Executar atualização de documento"""
        document = await self.document_repo.get_by_id(document_id)
        if not document:
            return None
        
        if title:
            document.title = title
        if content:
            document.content = content
        
        document.updated_at = datetime.utcnow()
        
        return await self.document_repo.update(document)


class DeleteDocumentUseCase:
    """Caso de uso para deletar documento"""
    
    def __init__(self, document_repo: DocumentRepository, file_storage: FileStorage):
        self.document_repo = document_repo
        self.file_storage = file_storage
    
    async def execute(self, document_id: str) -> bool:
        """Executar deleção de documento"""
        document = await self.document_repo.get_by_id(document_id)
        if not document:
            return False
        
        # Deletar arquivo se existir
        if document.file_path:
            await self.file_storage.delete(document.file_path)
        
        # Deletar documento
        return await self.document_repo.delete(document_id)
