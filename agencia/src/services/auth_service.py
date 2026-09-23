import time

import jwt

import config

ALGORITMO = "HS256"

EXPIRACAO_TOKEN_USUARIO_SEGUNDOS = 60 * 60
EXPIRACAO_TOKEN_SERVICO_SEGUNDOS = 60

PAPEL_ADMIN = "admin"


def gerar_token_usuario(usuario, papel):
    agora = int(time.time())
    payload = {
        "sub": usuario,
        "papel": papel,
        "tipo": "usuario",
        "iat": agora,
        "exp": agora + EXPIRACAO_TOKEN_USUARIO_SEGUNDOS,
    }
    return jwt.encode(payload, config.JWT_SECRET_KEY, algorithm=ALGORITMO)


def gerar_token_servico(id_agencia):
    agora = int(time.time())
    payload = {
        "sub": f"agencia-{id_agencia}",
        "tipo": "servico",
        "iat": agora,
        "exp": agora + EXPIRACAO_TOKEN_SERVICO_SEGUNDOS,
    }
    return jwt.encode(payload, config.JWT_SECRET_KEY, algorithm=ALGORITMO)


def decodificar_token(token):
    return jwt.decode(token, config.JWT_SECRET_KEY, algorithms=[ALGORITMO])


def pode_operar_conta(payload, conta):
    if payload.get("papel") == PAPEL_ADMIN:
        return True
    return conta.get("dono") == payload.get("sub")
