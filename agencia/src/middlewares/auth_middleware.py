from functools import wraps

import jwt
from flask import jsonify, request

from services import auth_service


def requer_token(tipos_permitidos=("usuario",)):
    """Exige um JWT válido no cabeçalho Authorization: Bearer <token>.

    tipos_permitidos restringe quais tokens a rota aceita: rotas de conta só
    aceitam "usuario" (emitido pelo /auth/login), e creditar-remoto só aceita
    "servico" (emitido internamente por outra agência) - um token não serve
    para a rota do outro, mesmo sendo assinado com a mesma chave.
    """

    def decorador(view_func):
        @wraps(view_func)
        def rota_protegida(*args, **kwargs):
            cabecalho = request.headers.get("Authorization", "")
            if not cabecalho.startswith("Bearer "):
                return jsonify({"erro": "Token ausente. Envie 'Authorization: Bearer <token>'."}), 401

            token = cabecalho[len("Bearer "):].strip()

            try:
                payload = auth_service.decodificar_token(token)
            except jwt.ExpiredSignatureError:
                return jsonify({"erro": "Token expirado."}), 401
            except jwt.InvalidTokenError:
                return jsonify({"erro": "Token inválido."}), 401

            if payload.get("tipo") not in tipos_permitidos:
                return jsonify({"erro": "Este token não é aceito nesta rota."}), 401

            request.token_payload = payload
            return view_func(*args, **kwargs)

        return rota_protegida

    return decorador
