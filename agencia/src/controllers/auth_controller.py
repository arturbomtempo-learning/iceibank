from flask import jsonify, request
from werkzeug.security import check_password_hash

import config
from services import auth_service


def login():
    corpo = request.get_json(silent=True) or {}
    usuario = corpo.get("usuario")
    senha = corpo.get("senha")

    hash_armazenado = config.USUARIOS.get(usuario)

    if hash_armazenado is None or not check_password_hash(hash_armazenado, senha or ""):
        return jsonify({"erro": "Usuário ou senha inválidos."}), 401

    token = auth_service.gerar_token_usuario(usuario)
    return jsonify({"token": token, "expiraEmSegundos": auth_service.EXPIRACAO_TOKEN_USUARIO_SEGUNDOS})
