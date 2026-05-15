from dataclasses import dataclass
from typing import Optional
from datetime import datetime


@dataclass
class Document:
    """Entidade de domínio para Documento"""
    document_id: str
    title: str
    content: str
    user_id: str
    created_at: datetime
    updated_at: datetime
    file_path: Optional[str] = None
    status: str = "active"
    
    def to_dict(self):
        return {
            "documentId": self.document_id,
            "title": self.title,
            "content": self.content,
            "userId": self.user_id,
            "createdAt": self.created_at.isoformat(),
            "updatedAt": self.updated_at.isoformat(),
            "filePath": self.file_path,
            "status": self.status
        }
