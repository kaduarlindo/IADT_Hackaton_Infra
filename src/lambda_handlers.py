from src.adapters.inbound.controllers import DocumentController, FileController
import asyncio
import json
import logging
import traceback

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Instanciar controllers
document_controller = DocumentController()
file_controller = FileController()

# Headers CORS padrão
CORS_HEADERS = {
    'Content-Type': 'application/json',
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
    'Access-Control-Allow-Headers': 'Content-Type, Authorization'
}


def build_response(status_code, body, headers=None):
    """Construir resposta Lambda com CORS"""
    if headers is None:
        headers = CORS_HEADERS
    else:
        headers.update(CORS_HEADERS)
    
    return {
        'statusCode': status_code,
        'body': json.dumps(body) if isinstance(body, dict) else body,
        'headers': headers
    }


def crud_handler(event, context):
    """Lambda handler para operações CRUD de documentos"""
    try:
        logger.info(f"CRUD Handler invoked: {event.get('httpMethod')} {event.get('path')}")
        
        # Lidar com preflight CORS
        if event.get('httpMethod') == 'OPTIONS':
            return build_response(200, {'message': 'OK'})
        
        http_method = event.get('httpMethod')
        path = event.get('path', '')
        
        # Rotas
        if path == '/documents' or path.endswith('/documents'):
            if http_method == 'POST':
                result = asyncio.run(document_controller.handle_create(event))
                return result
            elif http_method == 'GET':
                result = asyncio.run(document_controller.handle_list(event))
                return result
        elif '/documents/' in path:
            if http_method == 'GET':
                result = asyncio.run(document_controller.handle_get(event))
                return result
            elif http_method == 'PUT':
                result = asyncio.run(document_controller.handle_update(event))
                return result
            elif http_method == 'DELETE':
                result = asyncio.run(document_controller.handle_delete(event))
                return result
        
        return build_response(400, {'error': 'Invalid request'})
        
    except Exception as e:
        logger.error(f"Error in crud_handler: {str(e)}")
        logger.error(traceback.format_exc())
        return build_response(500, {'error': 'Internal server error', 'message': str(e)})


def pdf_handler(event, context):
    """Lambda handler para geração de PDF"""
    try:
        logger.info(f"PDF Handler invoked: {event.get('httpMethod')}")
        
        if event.get('httpMethod') == 'OPTIONS':
            return build_response(200, {'message': 'OK'})
        
        result = asyncio.run(file_controller.handle_pdf_generation(event))
        return result
        
    except Exception as e:
        logger.error(f"Error in pdf_handler: {str(e)}")
        logger.error(traceback.format_exc())
        return build_response(500, {'error': 'Internal server error', 'message': str(e)})


def upload_handler(event, context):
    """Lambda handler para upload de arquivo"""
    try:
        logger.info(f"Upload Handler invoked: {event.get('httpMethod')}")
        
        if event.get('httpMethod') == 'OPTIONS':
            return build_response(200, {'message': 'OK'})
        
        result = asyncio.run(file_controller.handle_file_upload(event))
        return result
        
    except Exception as e:
        logger.error(f"Error in upload_handler: {str(e)}")
        logger.error(traceback.format_exc())
        return build_response(500, {'error': 'Internal server error', 'message': str(e)})
