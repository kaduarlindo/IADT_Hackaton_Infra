from abc import ABC, abstractmethod
from typing import Optional
from src.domain.file import File


class FileStorage(ABC):
    """Interface (porta) para armazenamento de arquivos"""
    
    @abstractmethod
    async def upload(self, file_path: str, content: bytes, metadata: dict = None) -> File:
        """Fazer upload de arquivo"""
        pass
    
    @abstractmethod
    async def download(self, file_path: str) -> bytes:
        """Baixar arquivo"""
        pass
    
    @abstractmethod
    async def delete(self, file_path: str) -> bool:
        """Deletar arquivo"""
        pass
    
    @abstractmethod
    async def get_signed_url(self, file_path: str, expiration: int = 3600) -> str:
        """Obter URL assinada para arquivo"""
        pass
