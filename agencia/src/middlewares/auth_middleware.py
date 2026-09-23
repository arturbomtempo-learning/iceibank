from functools import wraps

import jwt
from flask import jsonify, request

from services import auth_service


def _autenticar(tipos_permitidos):
    cabecalho = request.headers.get("Authorization", "")
    if not cabecalho.startswith("Bearer "):
        return None, (jsonify({"erro": "Token ausente. Envie 'Authorization: Bearer <token>'."}), 401)

    token = cabecalho[len("Bearer "):].strip()

    try:
        payload = auth_service.decodificar_token(token)
    except jwt.ExpiredSignatureError:
        return None, (jsonify({"erro": "Token expirado."}), 401)
    except jwt.InvalidTokenError:
        return None, (jsonify({"erro": "Token inválido."}), 401)

    if payload.get("tipo") not in tipos_permitidos:
        return None, (jsonify({"erro": "Este token não é aceito nesta rota."}), 403)

    return payload, None


def requer_autenticacao(view_func):
    @wraps(view_func)
    def rota_protegida(*args, **kwargs):
        payload, erro = _autenticar(("usuario",))
        if erro is not None:
            return erro

        request.token_payload = payload
        return view_func(*args, **kwargs)

    return rota_protegida


def requer_admin(view_func):
    @wraps(view_func)
    def rota_protegida(*args, **kwargs):
        payload, erro = _autenticar(("usuario",))
        if erro is not None:
            return erro

        if payload.get("papel") != auth_service.PAPEL_ADMIN:
            return jsonify({"erro": "Seu usuário não tem permissão para esta operação."}), 403

        request.token_payload = payload
        return view_func(*args, **kwargs)

    return rota_protegida


def requer_servico(view_func):
    @wraps(view_func)
    def rota_protegida(*args, **kwargs):
        payload, erro = _autenticar(("servico",))
        if erro is not None:
            return erro

        request.token_payload = payload
        return view_func(*args, **kwargs)

    return rota_protegida
