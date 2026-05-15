import boto3
import os
from datetime import datetime, timedelta
from src.domain.file import File
from src.ports.file_storage import FileStorage


class S3FileStorage(FileStorage):
    """Implementação do armazenamento de arquivos usando S3"""
    
    def __init__(self):
        self.s3_client = boto3.client('s3')
        self.bucket_name = os.environ.get('S3_BUCKET_NAME', 'hackaton-uploads')
    
    async def upload(self, file_path: str, content: bytes, metadata: dict = None) -> File:
        """Fazer upload de arquivo para S3"""
        try:
            metadata = metadata or {}
            
            self.s3_client.put_object(
                Bucket=self.bucket_name,
                Key=file_path,
                Body=content,
                ContentType=metadata.get('content_type', 'application/octet-stream'),
                Metadata={k: str(v) for k, v in metadata.items()}
            )
            
            # Criar objeto File
            file = File(
                file_id=metadata.get('file_id', file_path.split('/')[-1]),
                document_id=metadata.get('document_id', ''),
                bucket_name=self.bucket_name,
                s3_key=file_path,
                file_type=metadata.get('file_type', 'unknown'),
                file_size=len(content),
                uploaded_at=datetime.utcnow(),
                url=f"s3://{self.bucket_name}/{file_path}"
            )
            
            return file
        except Exception as e:
            print(f"Erro ao fazer upload para S3: {e}")
            raise
    
    async def download(self, file_path: str) -> bytes:
        """Baixar arquivo do S3"""
        try:
            response = self.s3_client.get_object(
                Bucket=self.bucket_name,
                Key=file_path
            )
            return response['Body'].read()
        except Exception as e:
            print(f"Erro ao baixar arquivo do S3: {e}")
            raise
    
    async def delete(self, file_path: str) -> bool:
        """Deletar arquivo do S3"""
        try:
            self.s3_client.delete_object(
                Bucket=self.bucket_name,
                Key=file_path
            )
            return True
        except Exception as e:
            print(f"Erro ao deletar arquivo do S3: {e}")
            raise
    
    async def get_signed_url(self, file_path: str, expiration: int = 3600) -> str:
        """Obter URL assinada para arquivo"""
        try:
            url = self.s3_client.generate_presigned_url(
                'get_object',
                Params={'Bucket': self.bucket_name, 'Key': file_path},
                ExpiresIn=expiration
            )
            return url
        except Exception as e:
            print(f"Erro ao gerar URL assinada: {e}")
            raise
