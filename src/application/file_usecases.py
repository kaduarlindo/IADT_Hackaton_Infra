import uuid
from io import BytesIO
from src.domain.file import File
from src.ports.file_storage import FileStorage
from src.ports.pdf_generator import PDFGenerator
from datetime import datetime


class GeneratePDFUseCase:
    """Caso de uso para gerar PDF"""
    
    def __init__(self, pdf_generator: PDFGenerator, file_storage: FileStorage):
        self.pdf_generator = pdf_generator
        self.file_storage = file_storage
    
    async def execute(self, document_id: str, title: str, content: str, user_id: str) -> File:
        """Executar geração de PDF"""
        # Gerar PDF
        pdf_content = await self.pdf_generator.generate(document_id, title, content)
        
        # Salvar PDF no S3
        file_id = str(uuid.uuid4())
        file_path = f"documents/{document_id}/exports/{file_id}.pdf"
        
        file = await self.file_storage.upload(
            file_path,
            pdf_content,
            {
                "document_id": document_id,
                "user_id": user_id,
                "file_type": "pdf",
                "title": title
            }
        )
        
        return file


class UploadFileUseCase:
    """Caso de uso para upload de arquivo"""
    
    def __init__(self, file_storage: FileStorage):
        self.file_storage = file_storage
    
    async def execute(self, document_id: str, file_name: str, content: bytes, user_id: str) -> File:
        """Executar upload de arquivo"""
        file_id = str(uuid.uuid4())
        file_path = f"documents/{document_id}/attachments/{file_name}"
        
        file = await self.file_storage.upload(
            file_path,
            content,
            {
                "document_id": document_id,
                "user_id": user_id,
                "file_name": file_name
            }
        )
        
        return file
