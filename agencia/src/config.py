# TODO: substitua pelo seu OFFSET pessoal (dois últimos dígitos da matrícula/RA),
# necessário apenas se for rodar em uma máquina compartilhada do laboratório.
OFFSET = 35

NUMERO_AGENCIAS = 3
PORTA_BASE = 4000 + OFFSET

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
