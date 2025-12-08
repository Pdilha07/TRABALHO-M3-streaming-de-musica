-- ============================================
-- SISTEMA DE STREAMING DE MÚSICA
-- Criação do Banco de Dados e Tabelas
-- ============================================

-- Criar banco de dados
CREATE DATABASE IF NOT EXISTS streaming_musica;
USE streaming_musica;

-- ============================================
-- TABELA USUARIO
-- ============================================
CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    senha VARCHAR(255) NOT NULL,
    data_nascimento DATE NOT NULL,
    tipo_assinatura ENUM('Free', 'Premium', 'Familia') NOT NULL DEFAULT 'Free',
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_email CHECK (email LIKE '%@%'),
    CONSTRAINT chk_idade CHECK (TIMESTAMPDIFF(YEAR, data_nascimento, CURDATE()) >= 13)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Índices para melhorar performance
CREATE INDEX idx_usuario_email ON usuario(email);
CREATE INDEX idx_usuario_tipo ON usuario(tipo_assinatura);

-- ============================================
-- TABELA ARTISTA
-- ============================================
CREATE TABLE artista (
    id_artista INT AUTO_INCREMENT PRIMARY KEY,
    nome_artistico VARCHAR(150) NOT NULL UNIQUE,
    nome_real VARCHAR(150),
    biografia TEXT,
    pais VARCHAR(100),
    foto_perfil VARCHAR(255),
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT chk_nome_artistico CHECK (LENGTH(nome_artistico) >= 2)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Índice para busca por nome
CREATE INDEX idx_artista_nome ON artista(nome_artistico);

-- ============================================
-- TABELA ALBUM
-- ============================================
CREATE TABLE album (
    id_album INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    ano_lancamento YEAR NOT NULL,
    capa VARCHAR(255),
    id_artista INT NOT NULL,
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_album_artista 
        FOREIGN KEY (id_artista) 
        REFERENCES artista(id_artista)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_ano_lancamento 
        CHECK (ano_lancamento >= 1900 AND ano_lancamento <= YEAR(CURDATE()))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Índices
CREATE INDEX idx_album_titulo ON album(titulo);
CREATE INDEX idx_album_artista ON album(id_artista);
CREATE INDEX idx_album_ano ON album(ano_lancamento);

-- ============================================
-- TABELA MUSICA
-- ============================================
CREATE TABLE musica (
    id_musica INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(255) NOT NULL,
    duracao INT NOT NULL COMMENT 'Duração em segundos',
    genero VARCHAR(50),
    arquivo_audio VARCHAR(255) NOT NULL,
    numero_faixa INT,
    id_album INT NOT NULL,
    data_cadastro TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_musica_album 
        FOREIGN KEY (id_album) 
        REFERENCES album(id_album)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,
    CONSTRAINT chk_duracao 
        CHECK (duracao > 0 AND duracao <= 3600),
    CONSTRAINT chk_numero_faixa 
        CHECK (numero_faixa > 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Índices
CREATE INDEX idx_musica_titulo ON musica(titulo);
CREATE INDEX idx_musica_genero ON musica(genero);
CREATE INDEX idx_musica_album ON musica(id_album);

-- ============================================
-- TABELA PLAYLIST
-- ============================================
CREATE TABLE playlist (
    id_playlist INT AUTO_INCREMENT PRIMARY KEY,
    nome VARCHAR(150) NOT NULL,
    descricao TEXT,
    publica BOOLEAN NOT NULL DEFAULT FALSE,
    id_usuario INT NOT NULL,
    data_criacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    data_atualizacao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_playlist_usuario 
        FOREIGN KEY (id_usuario) 
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_nome_playlist 
        CHECK (LENGTH(nome) >= 1 AND LENGTH(nome) <= 150)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Índices
CREATE INDEX idx_playlist_usuario ON playlist(id_usuario);
CREATE INDEX idx_playlist_publica ON playlist(publica);

-- ============================================
-- TABELA PLAYLIST_MUSICA (Relacionamento N:N)
-- ============================================
CREATE TABLE playlist_musica (
    id_playlist INT NOT NULL,
    id_musica INT NOT NULL,
    ordem INT NOT NULL,
    data_adicao TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (id_playlist, id_musica),
    CONSTRAINT fk_pm_playlist 
        FOREIGN KEY (id_playlist) 
        REFERENCES playlist(id_playlist)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_pm_musica 
        FOREIGN KEY (id_musica) 
        REFERENCES musica(id_musica)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_ordem 
        CHECK (ordem > 0),
    CONSTRAINT uq_playlist_ordem 
        UNIQUE (id_playlist, ordem)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Índices
CREATE INDEX idx_pm_musica ON playlist_musica(id_musica);

-- ============================================
-- TABELA REPRODUCAO
-- ============================================
CREATE TABLE reproducao (
    id_reproducao INT AUTO_INCREMENT PRIMARY KEY,
    id_usuario INT NOT NULL,
    id_musica INT NOT NULL,
    data_hora TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    tempo_ouvido INT NOT NULL COMMENT 'Tempo em segundos',
    dispositivo VARCHAR(50),
    CONSTRAINT fk_reproducao_usuario 
        FOREIGN KEY (id_usuario) 
        REFERENCES usuario(id_usuario)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT fk_reproducao_musica 
        FOREIGN KEY (id_musica) 
        REFERENCES musica(id_musica)
        ON DELETE CASCADE
        ON UPDATE CASCADE,
    CONSTRAINT chk_tempo_ouvido 
        CHECK (tempo_ouvido >= 0)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Índices para relatórios e análises
CREATE INDEX idx_reproducao_usuario ON reproducao(id_usuario);
CREATE INDEX idx_reproducao_musica ON reproducao(id_musica);
CREATE INDEX idx_reproducao_data ON reproducao(data_hora);

-- ============================================
-- VIEWS ÚTEIS
-- ============================================

-- View: Músicas com informações completas
CREATE OR REPLACE VIEW vw_musicas_completas AS
SELECT 
    m.id_musica,
    m.titulo AS musica_titulo,
    m.duracao,
    m.genero,
    al.titulo AS album_titulo,
    al.ano_lancamento,
    ar.nome_artistico AS artista_nome,
    ar.pais AS artista_pais
FROM musica m
INNER JOIN album al ON m.id_album = al.id_album
INNER JOIN artista ar ON al.id_artista = ar.id_artista;

-- View: Estatísticas de reprodução por música
CREATE OR REPLACE VIEW vw_estatisticas_musica AS
SELECT 
    m.id_musica,
    m.titulo,
    ar.nome_artistico,
    COUNT(r.id_reproducao) AS total_reproducoes,
    COUNT(DISTINCT r.id_usuario) AS usuarios_unicos,
    ROUND(SUM(r.tempo_ouvido) / 3600, 2) AS horas_totais_ouvidas,
    ROUND(COUNT(r.id_reproducao) * 0.004, 2) AS royalties_gerados
FROM musica m
LEFT JOIN album al ON m.id_album = al.id_album
LEFT JOIN artista ar ON al.id_artista = ar.id_artista
LEFT JOIN reproducao r ON m.id_musica = r.id_musica AND r.tempo_ouvido >= 30
GROUP BY m.id_musica, m.titulo, ar.nome_artistico;

-- ============================================
-- POPULAÇÃO DO BANCO DE DADOS
-- ============================================

-- Inserir Usuários
INSERT INTO usuario (nome, email, senha, data_nascimento, tipo_assinatura) VALUES
('Maria Silva', 'maria@email.com', MD5('senha123'), '1995-03-15', 'Premium'),
('João Santos', 'joao@email.com', MD5('senha123'), '1998-07-22', 'Free'),
('Ana Costa', 'ana@email.com', MD5('senha123'), '2000-11-10', 'Premium'),
('Carlos Oliveira', 'carlos@email.com', MD5('senha123'), '1992-05-30', 'Familia'),
('Juliana Souza', 'juliana@email.com', MD5('senha123'), '1997-09-18', 'Free');

-- Inserir Artistas
INSERT INTO artista (nome_artistico, nome_real, biografia, pais) VALUES
('The Beatles', 'John, Paul, George, Ringo', 'Banda britânica de rock formada em Liverpool em 1960.', 'Reino Unido'),
('Djavan', 'Djavan Caetano Viana', 'Cantor e compositor brasileiro de MPB.', 'Brasil'),
('Adele', 'Adele Laurie Blue Adkins', 'Cantora e compositora britânica de soul e pop.', 'Reino Unido'),
('Legião Urbana', 'Renato Russo, Dado Villa-Lobos, Marcelo Bonfá', 'Banda brasileira de rock formada em 1982.', 'Brasil'),
('Taylor Swift', 'Taylor Alison Swift', 'Cantora e compositora americana de pop e country.', 'Estados Unidos');

-- Inserir Álbuns
INSERT INTO album (titulo, ano_lancamento, id_artista) VALUES
('Abbey Road', 1969, 1),
('Let It Be', 1970, 1),
('Flor de Lis', 1995, 2),
('Vesúvio', 2018, 2),
('21', 2011, 3),
('25', 2015, 3),
('Dois', 1986, 4),
('As Quatro Estações', 1989, 4),
('1989', 2014, 5),
('Lover', 2019, 5);

-- Inserir Músicas
INSERT INTO musica (titulo, duracao, genero, arquivo_audio, numero_faixa, id_album) VALUES
-- The Beatles - Abbey Road
('Come Together', 259, 'Rock', '/audio/beatles/come_together.mp3', 1, 1),
('Something', 182, 'Rock', '/audio/beatles/something.mp3', 2, 1),
('Here Comes the Sun', 185, 'Rock', '/audio/beatles/here_comes_the_sun.mp3', 7, 1),

-- The Beatles - Let It Be
('Let It Be', 243, 'Rock', '/audio/beatles/let_it_be.mp3', 6, 2),
('Get Back', 189, 'Rock', '/audio/beatles/get_back.mp3', 10, 2),

-- Djavan - Flor de Lis
('Flor de Lis', 267, 'MPB', '/audio/djavan/flor_de_lis.mp3', 1, 3),
('Oceano', 298, 'MPB', '/audio/djavan/oceano.mp3', 2, 3),

-- Djavan - Vesúvio
('Vesúvio', 241, 'MPB', '/audio/djavan/vesuvio.mp3', 1, 4),
('Pra Você', 223, 'MPB', '/audio/djavan/pra_voce.mp3', 3, 4),

-- Adele - 21
('Rolling in the Deep', 228, 'Soul', '/audio/adele/rolling_in_the_deep.mp3', 1, 5),
('Someone Like You', 285, 'Pop', '/audio/adele/someone_like_you.mp3', 2, 5),
('Set Fire to the Rain', 242, 'Pop', '/audio/adele/set_fire_to_the_rain.mp3', 5, 5),

-- Adele - 25
('Hello', 295, 'Soul', '/audio/adele/hello.mp3', 1, 6),
('When We Were Young', 290, 'Pop', '/audio/adele/when_we_were_young.mp3', 3, 6),

-- Legião Urbana - Dois
('Tempo Perdido', 300, 'Rock Nacional', '/audio/legiao/tempo_perdido.mp3', 1, 7),
('Eduardo e Mônica', 273, 'Rock Nacional', '/audio/legiao/eduardo_e_monica.mp3', 5, 7),

-- Legião Urbana - As Quatro Estações
('Há Tempos', 320, 'Rock Nacional', '/audio/legiao/ha_tempos.mp3', 1, 8),
('Pais e Filhos', 325, 'Rock Nacional', '/audio/legiao/pais_e_filhos.mp3', 4, 8),

-- Taylor Swift - 1989
('Shake It Off', 219, 'Pop', '/audio/taylor/shake_it_off.mp3', 6, 9),
('Blank Space', 231, 'Pop', '/audio/taylor/blank_space.mp3', 2, 9),

-- Taylor Swift - Lover
('Lover', 221, 'Pop', '/audio/taylor/lover.mp3', 3, 10),
('You Need to Calm Down', 171, 'Pop', '/audio/taylor/you_need_to_calm_down.mp3', 14, 10);

-- Inserir Playlists
INSERT INTO playlist (nome, descricao, publica, id_usuario) VALUES
('Minhas Favoritas', 'Músicas que eu mais gosto', FALSE, 1),
('Rock Clássico', 'As melhores do rock internacional', TRUE, 1),
('MPB Relax', 'MPB para relaxar', TRUE, 2),
('Hits Pop', 'Sucessos do pop internacional', TRUE, 3),
('Treino Pesado', 'Músicas para malhar', FALSE, 4);

-- Inserir Músicas nas Playlists
INSERT INTO playlist_musica (id_playlist, id_musica, ordem) VALUES
-- Playlist 1 (Minhas Favoritas)
(1, 10, 1), -- Rolling in the Deep
(1, 13, 2), -- Hello
(1, 3, 3),  -- Here Comes the Sun
(1, 6, 4),  -- Flor de Lis

-- Playlist 2 (Rock Clássico)
(2, 1, 1),  -- Come Together
(2, 2, 2),  -- Something
(2, 4, 3),  -- Let It Be
(2, 15, 4), -- Tempo Perdido

-- Playlist 3 (MPB Relax)
(3, 6, 1),  -- Flor de Lis
(3, 7, 2),  -- Oceano
(3, 8, 3),  -- Vesúvio
(3, 9, 4),  -- Pra Você

-- Playlist 4 (Hits Pop)
(4, 18, 1), -- Shake It Off
(4, 19, 2), -- Blank Space
(4, 10, 3), -- Rolling in the Deep
(4, 11, 4), -- Someone Like You

-- Playlist 5 (Treino Pesado)
(5, 10, 1), -- Rolling in the Deep
(5, 18, 2), -- Shake It Off
(5, 1, 3),  -- Come Together
(5, 5, 4);  -- Get Back

-- Inserir Reproduções
INSERT INTO reproducao (id_usuario, id_musica, tempo_ouvido, dispositivo) VALUES
-- Maria (id 1) - Premium
(1, 10, 228, 'Web'),
(1, 10, 220, 'Mobile'),
(1, 13, 295, 'Web'),
(1, 3, 185, 'Desktop'),
(1, 6, 267, 'Web'),

-- João (id 2) - Free
(2, 6, 150, 'Mobile'),
(2, 7, 298, 'Mobile'),
(2, 8, 180, 'Web'),

-- Ana (id 3) - Premium
(3, 18, 219, 'Desktop'),
(3, 19, 231, 'Desktop'),
(3, 10, 228, 'Mobile'),
(3, 11, 285, 'Web'),
(3, 13, 295, 'Desktop'),

-- Carlos (id 4) - Família
(4, 1, 259, 'Mobile'),
(4, 15, 300, 'Desktop'),
(4, 16, 273, 'Desktop'),
(4, 17, 320, 'Web'),

-- Juliana (id 5) - Free
(5, 20, 171, 'Mobile'),
(5, 18, 100, 'Mobile'),
(5, 2, 182, 'Web');

-- ============================================
-- QUERIES ÚTEIS PARA RELATÓRIOS
-- ============================================

-- Top 10 músicas mais tocadas
-- SELECT * FROM vw_estatisticas_musica ORDER BY total_reproducoes DESC LIMIT 10;

-- Músicas de um artista específico
-- SELECT * FROM vw_musicas_completas WHERE artista_nome = 'Adele';

-- Histórico de reprodução de um usuário
-- SELECT u.nome, m.titulo, ar.nome_artistico, r.data_hora, r.tempo_ouvido
-- FROM reproducao r
-- INNER JOIN usuario u ON r.id_usuario = u.id_usuario
-- INNER JOIN musica m ON r.id_musica = m.id_musica
-- INNER JOIN album al ON m.id_album = al.id_album
-- INNER JOIN artista ar ON al.id_artista = ar.id_artista
-- WHERE r.id_usuario = 1
-- ORDER BY r.data_hora DESC;

-- Total de playlists públicas
-- SELECT COUNT(*) as total_playlists_publicas FROM playlist WHERE publica = TRUE;

-- Usuários por tipo de assinatura
-- SELECT tipo_assinatura, COUNT(*) as total FROM usuario GROUP BY tipo_assinatura;