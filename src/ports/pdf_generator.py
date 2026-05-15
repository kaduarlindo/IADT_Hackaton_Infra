from abc import ABC, abstractmethod


class PDFGenerator(ABC):
    """Interface (porta) para geração de PDF"""
    
    @abstractmethod
    async def generate(self, document_id: str, title: str, content: str) -> bytes:
        """Gerar PDF a partir de conteúdo"""
        pass
    
    @abstractmethod
    async def generate_from_html(self, html_content: str) -> bytes:
        """Gerar PDF a partir de HTML"""
        pass
