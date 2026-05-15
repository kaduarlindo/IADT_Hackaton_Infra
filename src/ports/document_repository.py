from abc import ABC, abstractmethod
from typing import List, Optional
from src.domain.document import Document


class DocumentRepository(ABC):
    """Interface (porta) para repositório de documentos"""
    
    @abstractmethod
    async def save(self, document: Document) -> Document:
        """Salvar documento"""
        pass
    
    @abstractmethod
    async def get_by_id(self, document_id: str) -> Optional[Document]:
        """Obter documento pelo ID"""
        pass
    
    @abstractmethod
    async def list_by_user(self, user_id: str, limit: int = 10, offset: int = 0) -> List[Document]:
        """Listar documentos do usuário"""
        pass
    
    @abstractmethod
    async def update(self, document: Document) -> Document:
        """Atualizar documento"""
        pass
    
    @abstractmethod
    async def delete(self, document_id: str) -> bool:
        """Deletar documento"""
        pass
