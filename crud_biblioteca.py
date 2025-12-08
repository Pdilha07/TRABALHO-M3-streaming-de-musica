class Database:
    def __init__(self):
        try:
            self.con = mysql.connector.connect(
                host="localhost",
                port=3307,   # <<< AQUI ESTÁ A NOVA PORTA!!!
                user="root",
                password="",  # coloque se tiver senha
                database="streaming_musica"
            )

            if self.con.is_connected():
                self.cursor = self.con.cursor(dictionary=True)
                print("Conectado ao MySQL (XAMPP) com sucesso!")
            else:
                self.cursor = None
                print("Falha ao conectar ao MySQL!")

        except Error as e:
            print("Erro ao conectar:", e)
            self.con = None
            self.cursor = None

    def executar(self, sql, valores=None):
        if self.cursor is None:
            print("ERRO: Conexão não estabelecida.")
            return None

        try:
            self.cursor.execute(sql, valores)
            self.con.commit()
            return self.cursor

        except Error as e:
            print("Erro ao executar SQL:", e)
            return None
            
if __name__ == "__main__":
    print("\n========= TESTE DO SISTEMA =========\n")

    # TESTE DE INSERÇÃO
    print("Inserindo usuário...")
    UsuarioDAO.criar("Pedro", "pedro@gmail.com", "1234", "2000-01-01", "premium")

    print("Inserindo artista...")
    ArtistaDAO.criar("Zé Artista", "José da Silva", "Um cantor famoso", "Brasil")

    print("Inserindo playlist...")
    PlaylistDAO.criar("Favoritas", "Minhas músicas", True, 1)

    print("\nUsuários cadastrados:")
    for u in UsuarioDAO.listar():
        print(u)

    print("\nArtistas cadastrados:")
    for a in ArtistaDAO.listar():
        print(a)

    print("\nPlaylists cadastradas:")
    for p in PlaylistDAO.listar():
        print(p)
