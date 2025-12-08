import mysql.connector
from mysql.connector import Error

class Database:
    def __init__(self):
        try:
            self.con = mysql.connector.connect(
                host="localhost",
                user="root",
                password="",     # coloque sua senha aqui, se tiver
                database="streaming_musica",
                port=3307        # SUA PORTA NOVA !!!
            )
            self.cursor = self.con.cursor(dictionary=True)
            print("✔ Conectado ao MySQL!")
        except Error as e:
            print("❌ Erro ao conectar no MySQL:", e)

    def executar(self, sql, valores=None):
        try:
            self.cursor.execute(sql, valores)
            self.con.commit()
            return self.cursor
        except Error as e:
            print("❌ Erro SQL:", e)
            return None

db = Database()
