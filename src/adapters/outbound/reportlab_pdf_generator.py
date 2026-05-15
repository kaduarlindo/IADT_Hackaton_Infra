import io
from reportlab.lib.pagesizes import letter
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer
from reportlab.lib.units import inch
from src.ports.pdf_generator import PDFGenerator


class ReportLabPDFGenerator(PDFGenerator):
    """Implementação de gerador de PDF usando ReportLab"""
    
    async def generate(self, document_id: str, title: str, content: str) -> bytes:
        """Gerar PDF a partir de conteúdo"""
        buffer = io.BytesIO()
        
        # Criar documento PDF
        doc = SimpleDocTemplate(buffer, pagesize=letter)
        styles = getSampleStyleSheet()
        
        # Criar estilos customizados
        title_style = ParagraphStyle(
            'CustomTitle',
            parent=styles['Heading1'],
            fontSize=24,
            textColor='#2c3e50',
            spaceAfter=30,
            alignment=1  # Centro
        )
        
        content_style = ParagraphStyle(
            'CustomBody',
            parent=styles['Normal'],
            fontSize=11,
            alignment=4  # Justificado
        )
        
        # Construir elementos do documento
        elements = []
        
        # Adicionar título
        elements.append(Paragraph(title, title_style))
        elements.append(Spacer(1, 0.3*inch))
        
        # Adicionar conteúdo
        for paragraph in content.split('\n'):
            if paragraph.strip():
                elements.append(Paragraph(paragraph, content_style))
                elements.append(Spacer(1, 0.2*inch))
        
        # Construir o PDF
        doc.build(elements)
        
        # Obter bytes
        buffer.seek(0)
        return buffer.getvalue()
    
    async def generate_from_html(self, html_content: str) -> bytes:
        """Gerar PDF a partir de HTML"""
        # Implementação simplificada
        # Em produção, usar xhtml2pdf ou weasyprint
        buffer = io.BytesIO()
        
        doc = SimpleDocTemplate(buffer, pagesize=letter)
        styles = getSampleStyleSheet()
        
        elements = [Paragraph(html_content, styles['Normal'])]
        
        doc.build(elements)
        
        buffer.seek(0)
        return buffer.getvalue()
