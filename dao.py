from database import db

# ==============================
# USUARIO DAO
# ==============================

class UsuarioDAO:

    @staticmethod
    def listar():
        sql = "SELECT * FROM usuario ORDER BY id_usuario"
        return db.executar(sql).fetchall()

    @staticmethod
    def buscar(id):
        sql = "SELECT * FROM usuario WHERE id_usuario = %s"
        return db.executar(sql, (id,)).fetchone()

    @staticmethod
    def criar(nome, email, senha, data_nascimento, tipo):
        sql = """
            INSERT INTO usuario (nome, email, senha, data_nascimento, tipo_assinatura)
            VALUES (%s, %s, MD5(%s), %s, %s)
        """
        db.executar(sql, (nome, email, senha, data_nascimento, tipo))

    @staticmethod
    def atualizar(id, nome, email, tipo):
        sql = """
            UPDATE usuario
            SET nome=%s, email=%s, tipo_assinatura=%s
            WHERE id_usuario=%s
        """
        db.executar(sql, (nome, email, tipo, id))

    @staticmethod
    def deletar(id):
        sql = "DELETE FROM usuario WHERE id_usuario = %s"
        db.executar(sql, (id,))

# ==============================
# ARTISTA DAO
# ==============================

class ArtistaDAO:

    @staticmethod
    def listar():
        return db.executar("SELECT * FROM artista ORDER BY id_artista").fetchall()

    @staticmethod
    def buscar(id):
        return db.executar("SELECT * FROM artista WHERE id_artista = %s", (id,)).fetchone()

    @staticmethod
    def criar(nome_art, nome_real, bio, pais):
        sql = """
            INSERT INTO artista (nome_artistico, nome_real, biografia, pais)
            VALUES (%s, %s, %s, %s)
        """
        db.executar(sql, (nome_art, nome_real, bio, pais))

    @staticmethod
    def atualizar(id, nome_art, nome_real, bio, pais):
        sql = """
            UPDATE artista
            SET nome_artistico=%s, nome_real=%s, biografia=%s, pais=%s
            WHERE id_artista=%s
        """
        db.executar(sql, (nome_art, nome_real, bio, pais, id))

    @staticmethod
    def deletar(id):
        db.executar("DELETE FROM artista WHERE id_artista = %s", (id,))

# ==============================
# ALBUM DAO
# ==============================

class AlbumDAO:

    @staticmethod
    def listar():
        sql = """
            SELECT album.*, artista.nome_artistico
            FROM album
            INNER JOIN artista ON artista.id_artista = album.id_artista
            ORDER BY id_album
        """
        return db.executar(sql).fetchall()

    @staticmethod
    def buscar(id):
        return db.executar("SELECT * FROM album WHERE id_album = %s", (id,)).fetchone()

    @staticmethod
    def criar(titulo, ano, id_artista):
        sql = """
            INSERT INTO album (titulo, ano_lancamento, id_artista)
            VALUES (%s, %s, %s)
        """
        db.executar(sql, (titulo, ano, id_artista))

    @staticmethod
    def atualizar(id, titulo, ano, id_artista):
        sql = """
            UPDATE album
            SET titulo=%s, ano_lancamento=%s, id_artista=%s
            WHERE id_album=%s
        """
        db.executar(sql, (titulo, ano, id_artista, id))

    @staticmethod
    def deletar(id):
        db.executar("DELETE FROM album WHERE id_album = %s", (id,))

# ==============================
# MUSICA DAO
# ==============================

class MusicaDAO:

    @staticmethod
    def listar():
        sql = """
            SELECT musica.*, album.titulo AS album_nome
            FROM musica
            INNER JOIN album ON album.id_album = musica.id_album
            ORDER BY id_musica
        """
        return db.executar(sql).fetchall()

    @staticmethod
    def buscar(id):
        return db.executar("SELECT * FROM musica WHERE id_musica = %s", (id,)).fetchone()

    @staticmethod
    def criar(titulo, duracao, genero, arquivo, faixa, id_album):
        sql = """
            INSERT INTO musica (titulo, duracao, genero, arquivo_audio, numero_faixa, id_album)
            VALUES (%s, %s, %s, %s, %s, %s)
        """
        db.executar(sql, (titulo, duracao, genero, arquivo, faixa, id_album))

    @staticmethod
    def atualizar(id, titulo, duracao, genero, arquivo, faixa):
        sql = """
            UPDATE musica
            SET titulo=%s, duracao=%s, genero=%s, arquivo_audio=%s, numero_faixa=%s
            WHERE id_musica=%s
        """
        db.executar(sql, (titulo, duracao, genero, arquivo, faixa, id))

    @staticmethod
    def deletar(id):
        db.executar("DELETE FROM musica WHERE id_musica = %s", (id,))

# ==============================
# PLAYLIST DAO
# ==============================

class PlaylistDAO:

    @staticmethod
    def listar():
        sql = """
            SELECT playlist.*, usuario.nome AS usuario_nome
            FROM playlist
            INNER JOIN usuario ON usuario.id_usuario = playlist.id_usuario
            ORDER BY id_playlist
        """
        return db.executar(sql).fetchall()

    @staticmethod
    def buscar(id):
        return db.executar("SELECT * FROM playlist WHERE id_playlist = %s", (id,)).fetchone()

    @staticmethod
    def criar(nome, descricao, publica, id_usuario):
        sql = """
            INSERT INTO playlist (nome, descricao, publica, id_usuario)
            VALUES (%s, %s, %s, %s)
        """
        db.executar(sql, (nome, descricao, publica, id_usuario))

    @staticmethod
    def atualizar(id, nome, descricao, publica):
        sql = """
            UPDATE playlist
            SET nome=%s, descricao=%s, publica=%s
            WHERE id_playlist=%s
        """
        db.executar(sql, (nome, descricao, publica, id))

    @staticmethod
    def deletar(id):
        db.executar("DELETE FROM playlist WHERE id_playlist = %s", (id,))

# ==============================
# PLAYLIST_MUSICA (VINCULAR MÚSICAS)
# ==============================

class PlaylistMusicaDAO:

    @staticmethod
    def listar_musicas_da_playlist(id_playlist):
        sql = """
            SELECT playlist_musica.*, musica.titulo
            FROM playlist_musica
            INNER JOIN musica ON musica.id_musica = playlist_musica.id_musica
            WHERE id_playlist = %s
            ORDER BY ordem
        """
        return db.executar(sql, (id_playlist,)).fetchall()

    @staticmethod
    def adicionar(id_playlist, id_musica):
        sql_ordem = """
            SELECT COALESCE(MAX(ordem),0)+1 AS nova_ordem
            FROM playlist_musica
            WHERE id_playlist = %s
        """
        nova_ordem = db.executar(sql_ordem, (id_playlist,)).fetchone()["nova_ordem"]

        sql = """
            INSERT INTO playlist_musica (id_playlist, id_musica, ordem)
            VALUES (%s, %s, %s)
        """
        db.executar(sql, (id_playlist, id_musica, nova_ordem))

    @staticmethod
    def remover(id):
        db.executar("DELETE FROM playlist_musica WHERE id_playlist_musica = %s", (id,))
