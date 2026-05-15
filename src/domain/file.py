from dataclasses import dataclass
from typing import Optional
from datetime import datetime


@dataclass
class File:
    """Entidade de domínio para Arquivo"""
    file_id: str
    document_id: str
    bucket_name: str
    s3_key: str
    file_type: str
    file_size: int
    uploaded_at: datetime
    url: Optional[str] = None
    
    def to_dict(self):
        return {
            "fileId": self.file_id,
            "documentId": self.document_id,
            "bucketName": self.bucket_name,
            "s3Key": self.s3_key,
            "fileType": self.file_type,
            "fileSize": self.file_size,
            "uploadedAt": self.uploaded_at.isoformat(),
            "url": self.url
        }
