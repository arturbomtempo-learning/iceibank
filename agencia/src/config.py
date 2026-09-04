import os

from dotenv import load_dotenv
from werkzeug.security import generate_password_hash

load_dotenv()

OFFSET = 35

NUMERO_AGENCIAS = 3
PORTA_BASE = 4000 + OFFSET

try:
    JWT_SECRET_KEY = os.environ["JWT_SECRET_KEY"]
except KeyError as erro:
    raise RuntimeError(
        "JWT_SECRET_KEY não definido. Copie agencia/.env.example para agencia/.env "
        "(mesmo valor nas 3 agências) antes de subir o servidor."
    ) from erro

USUARIOS = {
    "aluno": generate_password_hash("banco123"),
}

AGENCIAS = [
    {"id": 0, "url": f"http://localhost:{PORTA_BASE}"},
    {"id": 1, "url": f"http://localhost:{PORTA_BASE + 1}"},
    {"id": 2, "url": f"http://localhost:{PORTA_BASE + 2}"},
]


def agencia_responsavel(id_conta):
    """Partição: cada conta pertence a exatamente uma agência."""
    return id_conta % NUMERO_AGENCIAS


def agencia_por_id(id_agencia):
    """Retorna a configuração da agência, ou None se o id não existir."""
    for agencia in AGENCIAS:
        if agencia["id"] == id_agencia:
            return agencia
    return None
