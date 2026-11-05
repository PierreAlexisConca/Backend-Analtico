import pyodbc
from dotenv import load_dotenv
import os

load_dotenv()

SQLSERVER_SERVER = os.getenv("SQLSERVER_SERVER")
SQLSERVER_DATABASE = os.getenv("SQLSERVER_DATABASE")
SQLSERVER_USERNAME = os.getenv("SQLSERVER_USERNAME")
SQLSERVER_PASSWORD = os.getenv("SQLSERVER_PASSWORD")


def get_sqlserver_connection():
    """
    Establece y retorna una conexión a SQL Server.
    """
    connection_string = (
        f"DRIVER={{ODBC Driver 18 for SQL Server}};"
        f"SERVER={SQLSERVER_SERVER};"
        f"DATABASE={SQLSERVER_DATABASE};"
        f"UID={SQLSERVER_USERNAME};"
        f"PWD={SQLSERVER_PASSWORD};"
        f"TrustServerCertificate=yes;"
        f"Encrypt=yes;"
    )
    
    return pyodbc.connect(connection_string)
