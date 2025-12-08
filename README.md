# 🎵 Sistema de Streaming de Música

Sistema web completo para gerenciamento de streaming de música, desenvolvido com Flask e MySQL. Permite o cadastro e gerenciamento de usuários, artistas, álbuns, músicas e playlists.
feito por: Pedro padilha e Lucas Eccel

## 📋 Funcionalidades

### Gerenciamento de Usuários
- ✅ Cadastro de novos usuários
- ✅ Listagem de usuários cadastrados
- ✅ Exclusão de usuários
- ✅ Tipos de assinatura (Free, Premium, Família)

### Gerenciamento de Artistas
- ✅ Cadastro de artistas com informações completas
- ✅ Nome artístico e nome real
- ✅ Biografia e país de origem
- ✅ Listagem de todos os artistas

### Gerenciamento de Álbuns
- ✅ Cadastro de álbuns vinculados a artistas
- ✅ Informações de título e ano de lançamento
- ✅ Listagem com dados do artista

### Gerenciamento de Músicas
- ✅ Cadastro de músicas com informações detalhadas
- ✅ Duração, gênero e arquivo de áudio
- ✅ Vinculação com álbuns
- ✅ Número da faixa no álbum

### Gerenciamento de Playlists
- ✅ Criação de playlists personalizadas
- ✅ Playlists públicas ou privadas
- ✅ Adição de músicas às playlists
- ✅ Controle de ordem das músicas
- ✅ Vinculação com usuários

## 🛠️ Tecnologias Utilizadas

- **Backend**: Flask (Python)
- **Frontend**: HTML5, Jinja2 Templates
- **Estilização**: Bootstrap 5.3
- **Banco de Dados**: MySQL
- **Servidor**: XAMPP

## 📁 Estrutura do Projeto

```
streaming-system/
│
├── templates/
│   ├── base.html              # Template base com navegação
│   ├── index.html             # Página inicial
│   ├── usuarios.html          # Lista de usuários
│   ├── usuarionv.html         # Cadastro de usuário
│   ├── artistas.html          # Lista de artistas
│   ├── artistasnv.html        # Cadastro de artista
│   ├── Albuns.html            # Lista de álbuns
│   ├── Albunnv.html           # Cadastro de álbum
│   ├── Musicas.html           # Lista de músicas
│   ├── Musicanv.html          # Cadastro de música
│   ├── playlist.html          # Lista de playlists
│   ├── playlistnv.html        # Cadastro de playlist
│   └── playlistAdd.html       # Gerenciar músicas da playlist
│
├── app.py                     # Arquivo principal da aplicação
└── README.md                  # Este arquivo
```

## 🚀 Como Executar

### Pré-requisitos

- Python 3.7+
- XAMPP (Apache e MySQL)
- pip (gerenciador de pacotes Python)

### Instalação

1. **Clone o repositório**
```bash
git clone https://github.com/seu-usuario/sistema-streaming.git
cd sistema-streaming
```

2. **Instale as dependências**
```bash
pip install flask mysql-connector-python
```

3. **Configure o XAMPP**
   - Inicie o Apache e MySQL pelo painel de controle do XAMPP
   - Acesse o phpMyAdmin (http://localhost/phpmyadmin)

4. **Crie o banco de dados**
```sql
CREATE DATABASE streaming;
USE streaming;

-- Execute os scripts de criação de tabelas aqui
-- (adicione seus scripts SQL de criação de tabelas)
```

5. **Execute a aplicação**
```bash
python app.py
```

6. **Acesse no navegador**
```
http://localhost:5000
```

## 🗄️ Estrutura do Banco de Dados

### Tabelas Principais

- **usuarios**: Armazena informações dos usuários do sistema
- **artistas**: Dados dos artistas musicais
- **albuns**: Álbuns musicais vinculados aos artistas
- **musicas**: Músicas vinculadas aos álbuns
- **playlists**: Playlists criadas pelos usuários
- **playlist_musicas**: Relacionamento N:N entre playlists e músicas

## 🎨 Interface

O sistema possui uma interface moderna e responsiva utilizando Bootstrap 5, com:
- Barra de navegação intuitiva
- Tabelas estilizadas para listagem de dados
- Formulários organizados para cadastros
- Botões de ação destacados
- Design responsivo para diferentes dispositivos

## 📝 Funcionalidades por Módulo

### Módulo de Usuários
- Cadastro com nome, email, senha, data de nascimento
- Seleção de tipo de assinatura
- Exclusão de usuários

### Módulo de Artistas
- Nome artístico e real
- Biografia completa
- País de origem

### Módulo de Álbuns
- Título do álbum
- Ano de lançamento
- Vínculo com artista

### Módulo de Músicas
- Título da música
- Duração em segundos
- Gênero musical
- Caminho do arquivo de áudio
- Número da faixa
- Vínculo com álbum

### Módulo de Playlists
- Nome e descrição
- Configuração de privacidade (pública/privada)
- Vínculo com usuário
- Adição e organização de músicas

## 🔧 Configuração

Certifique-se de configurar corretamente a conexão com o banco de dados no arquivo `app.py`:

```python
db_config = {
    'host': 'localhost',
    'user': 'root',
    'password': '',  # sua senha do MySQL
    'database': 'streaming'
}
```

## 📌 Observações

- Mantenha o XAMPP ativo durante a execução da aplicação
- Certifique-se de que as portas 80 (Apache) e 3306 (MySQL) estejam disponíveis
- Faça backup regular do banco de dados

## 🤝 Contribuindo

Contribuições são bem-vindas! Sinta-se à vontade para abrir issues ou enviar pull requests.

## 📄 Licença

Este projeto foi desenvolvido como trabalho acadêmico.

## ✨ Autor

Desenvolvido como projeto de sistema de streaming de música.

---

**Nota**: Este é um projeto educacional desenvolvido para fins de aprendizado.
