import React, { useState, useEffect } from 'react';
import axios from 'axios';
import './App.css';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:3000/api';

function App() {
  const [documents, setDocuments] = useState([]);
  const [loading, setLoading] = useState(false);
  const [newDoc, setNewDoc] = useState({ title: '', content: '' });
  const [selectedDoc, setSelectedDoc] = useState(null);

  useEffect(() => {
    fetchDocuments();
  }, []);

  const fetchDocuments = async () => {
    setLoading(true);
    try {
      const response = await axios.get(`${API_BASE_URL}/documents`);
      setDocuments(response.data);
    } catch (error) {
      console.error('Erro ao buscar documentos:', error);
    } finally {
      setLoading(false);
    }
  };

  const createDocument = async (e) => {
    e.preventDefault();
    if (!newDoc.title || !newDoc.content) {
      alert('Preencha título e conteúdo');
      return;
    }

    try {
      const response = await axios.post(`${API_BASE_URL}/documents`, newDoc);
      setDocuments([...documents, response.data]);
      setNewDoc({ title: '', content: '' });
      alert('Documento criado com sucesso!');
    } catch (error) {
      console.error('Erro ao criar documento:', error);
      alert('Erro ao criar documento');
    }
  };

  const generatePDF = async (doc) => {
    try {
      const response = await axios.post(`${API_BASE_URL}/pdf`, {
        document_id: doc.documentId,
        title: doc.title,
        content: doc.content
      });
      alert(`PDF gerado: ${response.data.fileId}`);
    } catch (error) {
      console.error('Erro ao gerar PDF:', error);
      alert('Erro ao gerar PDF');
    }
  };

  const deleteDocument = async (docId) => {
    if (!window.confirm('Tem certeza que deseja deletar?')) return;

    try {
      await axios.delete(`${API_BASE_URL}/documents/${docId}`);
      setDocuments(documents.filter(d => d.documentId !== docId));
      alert('Documento deletado com sucesso!');
    } catch (error) {
      console.error('Erro ao deletar documento:', error);
      alert('Erro ao deletar documento');
    }
  };

  return (
    <div className="app">
      <header>
        <h1>📄 Plataforma de Documentos</h1>
      </header>

      <main>
        <div className="container">
          {/* Formulário para criar documento */}
          <section className="form-section">
            <h2>Criar Novo Documento</h2>
            <form onSubmit={createDocument}>
              <div className="form-group">
                <label htmlFor="title">Título</label>
                <input
                  type="text"
                  id="title"
                  value={newDoc.title}
                  onChange={(e) => setNewDoc({ ...newDoc, title: e.target.value })}
                  placeholder="Digite o título do documento"
                />
              </div>

              <div className="form-group">
                <label htmlFor="content">Conteúdo</label>
                <textarea
                  id="content"
                  value={newDoc.content}
                  onChange={(e) => setNewDoc({ ...newDoc, content: e.target.value })}
                  placeholder="Digite o conteúdo do documento"
                  rows="6"
                ></textarea>
              </div>

              <button type="submit" className="btn btn-primary">
                Criar Documento
              </button>
            </form>
          </section>

          {/* Lista de documentos */}
          <section className="documents-section">
            <h2>Meus Documentos</h2>

            {loading ? (
              <p className="loading">Carregando...</p>
            ) : documents.length === 0 ? (
              <p className="empty">Nenhum documento ainda</p>
            ) : (
              <div className="documents-grid">
                {documents.map((doc) => (
                  <div
                    key={doc.documentId}
                    className="document-card"
                    onClick={() => setSelectedDoc(doc)}
                  >
                    <h3>{doc.title}</h3>
                    <p>{doc.content.substring(0, 100)}...</p>
                    <small>
                      {new Date(doc.createdAt).toLocaleDateString('pt-BR')}
                    </small>

                    <div className="card-actions">
                      <button
                        className="btn btn-small btn-pdf"
                        onClick={(e) => {
                          e.stopPropagation();
                          generatePDF(doc);
                        }}
                      >
                        📥 Gerar PDF
                      </button>
                      <button
                        className="btn btn-small btn-danger"
                        onClick={(e) => {
                          e.stopPropagation();
                          deleteDocument(doc.documentId);
                        }}
                      >
                        🗑️ Deletar
                      </button>
                    </div>
                  </div>
                ))}
              </div>
            )}
          </section>

          {/* Detalhes do documento selecionado */}
          {selectedDoc && (
            <section className="detail-section">
              <div className="modal-overlay" onClick={() => setSelectedDoc(null)}>
                <div className="modal-content" onClick={(e) => e.stopPropagation()}>
                  <button
                    className="close-btn"
                    onClick={() => setSelectedDoc(null)}
                  >
                    ✕
                  </button>
                  <h2>{selectedDoc.title}</h2>
                  <p className="content">{selectedDoc.content}</p>
                  <button
                    className="btn btn-primary"
                    onClick={() => {
                      generatePDF(selectedDoc);
                      setSelectedDoc(null);
                    }}
                  >
                    Gerar PDF
                  </button>
                </div>
              </div>
            </section>
          )}
        </div>
      </main>

      <footer>
        <p>&copy; 2024 Hackaton Platform. Todos os direitos reservados.</p>
      </footer>
    </div>
  );
}

export default App;
