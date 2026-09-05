from functools import wraps

import jwt
from flask import jsonify, request

from services import auth_service


def _autenticar(tipos_permitidos):
    """Autenticação: valida assinatura, expiração e tipo do token.

    Devolve (payload, None) quando o token serve, ou (None, resposta_de_erro)
    quando não serve. Token ausente, inválido ou expirado é 401 ("não sei quem
    você é"); token válido mas do tipo errado para a rota é 403 ("sei quem você
    é, mas esse token não vale aqui").
    """
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
    """Exige apenas um token de usuário válido, sem restringir papel."""

    @wraps(view_func)
    def rota_protegida(*args, **kwargs):
        payload, erro = _autenticar(("usuario",))
        if erro is not None:
            return erro

        request.token_payload = payload
        return view_func(*args, **kwargs)

    return rota_protegida


def requer_admin(view_func):
    """Autoriza por papel: além de autenticado, precisa ser o gerente da agência."""

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
    """Só aceita o token interno emitido por outra agência (rota creditar-remoto)."""

    @wraps(view_func)
    def rota_protegida(*args, **kwargs):
        payload, erro = _autenticar(("servico",))
        if erro is not None:
            return erro

        request.token_payload = payload
        return view_func(*args, **kwargs)

    return rota_protegida
