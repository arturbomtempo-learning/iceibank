import json
import os
import threading

from werkzeug.security import generate_password_hash

PAPEL_ADMIN = "admin"
PAPEL_CLIENTE = "cliente"

USUARIO_ADMIN_PADRAO = "admin"
SENHA_ADMIN_PADRAO = "admin1234"

_pasta_dados = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", "data")
_caminho_arquivo = os.path.join(_pasta_dados, "usuarios.json")
_lock = threading.Lock()


def _semear_admin():
    return {
        USUARIO_ADMIN_PADRAO: {
            "senha": generate_password_hash(SENHA_ADMIN_PADRAO),
            "papel": PAPEL_ADMIN,
        }
    }


def _ler_arquivo():
    if not os.path.exists(_caminho_arquivo):
        return None

    try:
        with open(_caminho_arquivo, encoding="utf-8") as arquivo:
            return json.load(arquivo)
    except (json.JSONDecodeError, OSError):
        return None


def _gravar_arquivo(usuarios):
    os.makedirs(_pasta_dados, exist_ok=True)

    caminho_temporario = f"{_caminho_arquivo}.tmp"
    with open(caminho_temporario, "w", encoding="utf-8") as arquivo:
        json.dump(usuarios, arquivo, ensure_ascii=False, indent=2)

    os.replace(caminho_temporario, _caminho_arquivo)


def _carregar():
    """As contas são particionadas entre as agências, mas as credenciais não: as 3
    agências leem este mesmo arquivo, então um correntista cadastrado em uma delas
    consegue entrar e receber conta em qualquer outra."""
    usuarios = _ler_arquivo()

    if not usuarios:
        usuarios = _semear_admin()
        _gravar_arquivo(usuarios)

    return usuarios


def buscar(usuario):
    if not isinstance(usuario, str):
        return None

    return _carregar().get(usuario)


def existe(usuario):
    return buscar(usuario) is not None


def criar_cliente(usuario, senha):
    """Cadastra um correntista. Retorna False se o usuário já existir."""
    with _lock:
        usuarios = _carregar()

        if usuario in usuarios:
            return False

        usuarios[usuario] = {
            "senha": generate_password_hash(senha),
            "papel": PAPEL_CLIENTE,
        }
        _gravar_arquivo(usuarios)

    return True
