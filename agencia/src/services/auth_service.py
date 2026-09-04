import time

import jwt

import config

ALGORITMO = "HS256"

EXPIRACAO_TOKEN_USUARIO_SEGUNDOS = 60 * 60  # 1 hora
EXPIRACAO_TOKEN_SERVICO_SEGUNDOS = 60  # token interno, usado uma única vez


def gerar_token_usuario(usuario):
    """Token emitido no login, usado pelo frontend nas chamadas em nome de uma pessoa."""
    agora = int(time.time())
    payload = {
        "sub": usuario,
        "tipo": "usuario",
        "iat": agora,
        "exp": agora + EXPIRACAO_TOKEN_USUARIO_SEGUNDOS,
    }
    return jwt.encode(payload, config.JWT_SECRET_KEY, algorithm=ALGORITMO)


def gerar_token_servico(id_agencia):
    """Token de curtíssima duração para a chamada agência-a-agência em creditar-remoto."""
    agora = int(time.time())
    payload = {
        "sub": f"agencia-{id_agencia}",
        "tipo": "servico",
        "iat": agora,
        "exp": agora + EXPIRACAO_TOKEN_SERVICO_SEGUNDOS,
    }
    return jwt.encode(payload, config.JWT_SECRET_KEY, algorithm=ALGORITMO)


def decodificar_token(token):
    """Levanta jwt.ExpiredSignatureError ou jwt.InvalidTokenError se o token não servir."""
    return jwt.decode(token, config.JWT_SECRET_KEY, algorithms=[ALGORITMO])
