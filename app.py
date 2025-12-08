from flask import Flask, render_template, request, redirect
from dao import UsuarioDAO, ArtistaDAO, AlbumDAO, MusicaDAO, PlaylistDAO, PlaylistMusicaDAO

app = Flask(__name__)

# ======================================================
# HOME
# ======================================================
@app.route('/')
def index():
    return render_template('index.html')


# ======================================================
# USUÁRIO
# ======================================================
@app.route('/usuarios')
def usuarios_listar():
    usuarios = UsuarioDAO.listar()
    return render_template('usuarios/listar.html', usuarios=usuarios)

@app.route('/usuarios/novo', methods=['GET', 'POST'])
def usuarios_novo():
    if request.method == 'POST':
        UsuarioDAO.criar(
            request.form['nome'],
            request.form['email'],
            request.form['senha'],
            request.form['data_nascimento'],
            request.form['tipo']
        )
        return redirect('/usuarios')
    return render_template('usuarios/novo.html')

@app.route('/usuarios/deletar/<int:id>')
def usuarios_deletar(id):
    UsuarioDAO.deletar(id)
    return redirect('/usuarios')


# ======================================================
# ARTISTA
# ======================================================
@app.route('/artistas')
def artistas_listar():
    artistas = ArtistaDAO.listar()
    return render_template('artistas/listar.html', artistas=artistas)

@app.route('/artistas/novo', methods=['GET', 'POST'])
def artistas_novo():
    if request.method == 'POST':
        ArtistaDAO.criar(
            request.form['nome_artistico'],
            request.form.get('nome_real'),
            request.form.get('biografia'),
            request.form.get('pais')
        )
        return redirect('/artistas')
    return render_template('artistas/novo.html')


# ======================================================
# ÁLBUM
# ======================================================
@app.route('/albuns')
def albuns_listar():
    albuns = AlbumDAO.listar()
    artistas = ArtistaDAO.listar()
    return render_template('albuns/listar.html', albuns=albuns, artistas=artistas)

@app.route('/albuns/novo', methods=['GET', 'POST'])
def albuns_novo():
    artistas = ArtistaDAO.listar()
    if request.method == 'POST':
        AlbumDAO.criar(
            request.form['titulo'],
            request.form['ano'],
            request.form['id_artista']
        )
        return redirect('/albuns')
    return render_template('albuns/novo.html', artistas=artistas)


# ======================================================
# MÚSICA
# ======================================================
@app.route('/musicas')
def musicas_listar():
    musicas = MusicaDAO.listar()
    albuns = AlbumDAO.listar()
    return render_template('musicas/listar.html', musicas=musicas, albuns=albuns)

@app.route('/musicas/novo', methods=['GET', 'POST'])
def musicas_novo():
    albuns = AlbumDAO.listar()
    if request.method == 'POST':
        MusicaDAO.criar(
            request.form['titulo'],
            request.form['duracao'],
            request.form['genero'],
            request.form['arquivo'],
            request.form['faixa'],
            request.form['id_album']
        )
        return redirect('/musicas')

    return render_template('musicas/novo.html', albuns=albuns)


# ======================================================
# PLAYLIST
# ======================================================
@app.route('/playlists')
def playlists_listar():
    playlists = PlaylistDAO.listar()
    return render_template('playlists/listar.html', playlists=playlists)

@app.route('/playlists/novo', methods=['GET', 'POST'])
def playlists_novo():
    usuarios = UsuarioDAO.listar()
    if request.method == 'POST':
        PlaylistDAO.criar(
            request.form['nome'],
            request.form.get('descricao'),
            request.form.get('publica') == "on",
            request.form['id_usuario']
        )
        return redirect('/playlists')
    return render_template('playlists/novo.html', usuarios=usuarios)


# ======================================================
# ADICIONAR MÚSICA NA PLAYLIST
# ======================================================
@app.route('/playlist/<int:id>/musicas')
def playlist_musicas(id):
    playlist = PlaylistDAO.buscar(id)
    musicas = PlaylistMusicaDAO.listar_musicas_da_playlist(id)
    todas_musicas = MusicaDAO.listar()
    return render_template('playlists/musicas.html', playlist=playlist, musicas=musicas, todas=todas_musicas)

@app.route('/playlist/<int:id_playlist>/adicionar', methods=['POST'])
def playlist_adicionar_musica(id_playlist):
    PlaylistMusicaDAO.adicionar(id_playlist, request.form['id_musica'])
    return redirect(f'/playlist/{id_playlist}/musicas')


# ======================================================
# RUN
# ======================================================
if __name__ == '__main__':
    app.run(debug=True, port=5000)
