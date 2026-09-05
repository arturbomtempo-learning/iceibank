from flask import jsonify, request
from werkzeug.security import check_password_hash

from services import auth_service, repositorio_usuarios


def login():
    corpo = request.get_json(silent=True) or {}
    usuario = corpo.get("usuario")
    senha = corpo.get("senha")

    dados = repositorio_usuarios.buscar(usuario)

    if dados is None or not check_password_hash(dados["senha"], senha or ""):
        return jsonify({"erro": "Usuário ou senha inválidos."}), 401

    token = auth_service.gerar_token_usuario(usuario, dados["papel"])
    return jsonify(
        {
            "token": token,
            "usuario": usuario,
            "papel": dados["papel"],
            "expiraEmSegundos": auth_service.EXPIRACAO_TOKEN_USUARIO_SEGUNDOS,
        }
    )
