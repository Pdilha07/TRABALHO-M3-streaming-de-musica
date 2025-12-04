# 📚 Sistema de Gerenciamento de Biblioteca

Projeto acadêmico desenvolvido para a disciplina de Banco de Dados da UNIVALI - Universidade do Vale do Itajaí.

## 👥 Autores
- Pedro Henrique silva  Padilha
- lucas Eccel

**Professor:** Maurício Pasetto de Freitas, MSc.

## 📋 Sobre o Projeto

Sistema completo de gerenciamento de biblioteca desenvolvido em Python com banco de dados MySQL, contemplando operações CRUD para gerenciamento de acervo, usuários e empréstimos.

### Funcionalidades

✅ **Gerenciamento de Categorias**
- Cadastro de categorias de livros
- Listagem e busca
- Atualização e remoção

✅ **Gerenciamento de Usuários**
- Cadastro de leitores e bibliotecários
- Validação de CPF e email
- Controle de perfis de acesso

✅ **Gerenciamento de Livros**
- Cadastro completo com ISBN
- Controle de quantidade e disponibilidade
- Busca por título e categoria

✅ **Gerenciamento de Empréstimos**
- Controle de empréstimos ativos
- Cálculo automático de multas
- Histórico completo de movimentações

## 🛠️ Tecnologias Utilizadas

- **Python 3.x** - Linguagem de programação
- **MySQL 8.0+** - Sistema de gerenciamento de banco de dados
- **mysql-connector-python** - Conector Python-MySQL

## 📊 Modelagem do Banco de Dados

### Diagrama Entidade-Relacionamento (DER)

O sistema é composto por 4 entidades principais:

1. **CATEGORIA** - Classificação dos livros
2. **USUARIO** - Leitores e bibliotecários
3. **LIVRO** - Acervo da biblioteca
4. **EMPRESTIMO** - Controle de empréstimos

### Relacionamentos

- USUARIO (1:N) EMPRESTIMO - Um usuário pode realizar vários empréstimos
- LIVRO (1:N) EMPRESTIMO - Um livro pode estar em vários empréstimos
- CATEGORIA (1:N) LIVRO - Uma categoria classifica vários livros

### Regras de Negócio

- **RN01:** Cada usuário pode emprestar no máximo 3 livros simultaneamente
- **RN02:** Prazo padrão de empréstimo: 14 dias
- **RN03:** Multa por atraso: R$ 2,00 por dia
- **RN04:** Usuários com multas pendentes não podem realizar novos empréstimos
- **RN05:** A quantidade disponível deve ser sempre ≤ quantidade total

## 🚀 Como Executar

### Pré-requisitos

```bash
# Python 3.x instalado
python --version

# MySQL 8.0+ instalado e rodando
mysql --version

# Instalar dependências
pip install mysql-connector-python
```

### Configuração do Banco de Dados

1. Execute o script SQL de criação:

```bash
mysql -u root -p < database/create_database.sql
```

2. Execute o script de população com dados de exemplo:

```bash
mysql -u root -p biblioteca < database/populate_database.sql
```

### Executando o Sistema

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/biblioteca-crud.git

# Entre no diretório
cd biblioteca-crud

# Execute o sistema
python src/main.py
```

### Configuração da Conexão

Edite o arquivo `src/main.py` com suas credenciais:

```python
db = DatabaseConnection(
    host='localhost',
    user='seu_usuario',
    password='sua_senha',
    database='biblioteca'
)
```

## 📁 Estrutura do Projeto

```
biblioteca-crud/
│
├── database/
│   ├── create_database.sql      # Script de criação do BD
│   └── populate_database.sql    # Script de população
│
├── src/
│   ├── main.py                  # Aplicação principal
│   ├── database_connection.py   # Gerenciador de conexão
│   ├── categoria_dao.py         # CRUD Categoria
│   ├── usuario_dao.py           # CRUD Usuario
│   ├── livro_dao.py             # CRUD Livro
│   └── emprestimo_dao.py        # CRUD Emprestimo
│
├── docs/
│   ├── DER.png                  # Diagrama Entidade-Relacionamento
│   ├── DR.png                   # Diagrama Relacional
│   └── projeto_completo.pdf     # Documentação completa
│
├── README.md
└── requirements.txt
```

## 💻 Exemplos de Uso

### Criando uma Categoria

```python
categoria_dao = CategoriaDAO(db)
categoria_dao.create('Ficção Científica', 'Livros de ficção científica')
```

### Cadastrando um Usuário

```python
usuario_dao = UsuarioDAO(db)
usuario_dao.create(
    nome='João Silva',
    cpf='12345678901',
    email='joao@email.com',
    telefone='47999998888',
    tipo='leitor'
)
```

### Registrando um Livro

```python
livro_dao = LivroDAO(db)
livro_dao.create(
    titulo='1984',
    isbn='9780451524935',
    ano_publicacao=1949,
    editora='Companhia das Letras',
    quantidade_total=3,
    id_categoria=1
)
```

### Criando um Empréstimo

```python
emprestimo_dao = EmprestimoDAO(db)
emprestimo_dao.create(
    id_usuario=1,
    id_livro=1,
    dias_emprestimo=14
)
```

### Realizando Devolução

```python
emprestimo_dao.realizar_devolucao(id_emprestimo=1)
# Sistema calcula automaticamente multas por atraso
```

## 📝 Normalização

O banco de dados está normalizado na **Terceira Forma Normal (3FN)**:

- ✅ Todos os atributos são atômicos (1FN)
- ✅ Todos os atributos não-chave dependem da chave primária completa (2FN)
- ✅ Não há dependências transitivas (3FN)

## 🔒 Constraints e Validações

- **Chaves Primárias:** Todas as tabelas possuem PKs auto-incrementais
- **Chaves Estrangeiras:** Relacionamentos garantidos com FKs
- **Unique:** CPF, email e ISBN são únicos
- **Check:** Validações de CPF, email, quantidades e datas
- **Not Null:** Campos obrigatórios definidos

## 📊 Queries Importantes

### Livros mais emprestados

```sql
SELECT l.titulo, COUNT(e.id_emprestimo) as total_emprestimos
FROM livro l
LEFT JOIN emprestimo e ON l.id_livro = e.id_livro
GROUP BY l.id_livro
ORDER BY total_emprestimos DESC
LIMIT 10;
```

### Usuários com empréstimos ativos

```sql
SELECT u.nome, COUNT(e.id_emprestimo) as emprestimos_ativos
FROM usuario u
INNER JOIN emprestimo e ON u.id_usuario = e.id_usuario
WHERE e.status = 'ativo'
GROUP BY u.id_usuario;
```

### Empréstimos em atraso

```sql
SELECT e.*, u.nome, l.titulo, 
       DATEDIFF(CURDATE(), e.data_prevista_devolucao) as dias_atraso
FROM emprestimo e
INNER JOIN usuario u ON e.id_usuario = u.id_usuario
INNER JOIN livro l ON e.id_livro = l.id_livro
WHERE e.status = 'ativo' 
  AND e.data_prevista_devolucao < CURDATE();
```

## 🎯 Melhorias Futuras

- [ ] Interface gráfica com Tkinter ou Flask
- [ ] Sistema de reservas para livros indisponíveis
- [ ] Notificações por email sobre vencimentos
- [ ] Relatórios gerenciais em PDF
- [ ] API RESTful com FastAPI
- [ ] Sistema de avaliação de livros
- [ ] Controle de patrimônio e localização física

## 📄 Licença

Este projeto foi desenvolvido para fins acadêmicos na disciplina de Banco de Dados da UNIVALI.

## 📧 Contato

Para dúvidas ou sugestões:
- Email: [seu-email@email.com]
- GitHub: [@seu-usuario](https://github.com/seu-usuario)

---

**UNIVALI - Universidade do Vale do Itajaí**  
**Escola Politécnica**  
**Disciplina: Banco de Dados**  
**Professor: Maurício Pasetto de Freitas, MSc.**
