import requests
from flask import current_app, jsonify, request

import config
from services import auth_service, repositorio_usuarios

TIMEOUT_SEGUNDOS = 5


def _estado():
    return (
        current_app.config["CONTAS"],
        current_app.config["ID_AGENCIA"],
    )


def _contas_locais(usuario, e_admin):
    contas, id_agencia = _estado()

    return [
        {**conta, "agencia": id_agencia}
        for conta in contas.values()
        if e_admin or conta.get("dono") == usuario
    ]


def _contas_de_outra_agencia(id_agencia_destino, usuario, id_agencia_origem):
    """Pergunta a outra agência quais contas daquele usuário ela guarda, usando um
    token de serviço próprio em vez de repassar o token de quem fez o login."""
    url_destino = config.agencia_por_id(id_agencia_destino)["url"]
    token_servico = auth_service.gerar_token_servico(id_agencia_origem)

    resposta = requests.get(
        f"{url_destino}/interno/contas/{usuario}",
        headers={"Authorization": f"Bearer {token_servico}"},
        timeout=TIMEOUT_SEGUNDOS,
    )
    resposta.raise_for_status()

    return resposta.json()


def listar_contas_para_servico(usuario):
    """Rota interna: só outra agência chama, com token de serviço. O papel vem do
    repositório de usuários, e não de um campo que a agência chamadora poderia forjar."""
    dados_usuario = repositorio_usuarios.buscar(usuario)
    e_admin = dados_usuario is not None and dados_usuario["papel"] == auth_service.PAPEL_ADMIN

    return jsonify(_contas_locais(usuario, e_admin))


def extrato_consolidado():
    """Funcionalidade adicional (seção 2.1): junta as contas do usuário nas três
    agências e devolve o saldo somado, mesmo estando em partições diferentes."""
    _, id_agencia = _estado()

    usuario = request.token_payload.get("sub")
    e_admin = request.token_payload.get("papel") == auth_service.PAPEL_ADMIN

    contas = _contas_locais(usuario, e_admin)
    agencias_indisponiveis = []

    for agencia in config.AGENCIAS:
        if agencia["id"] == id_agencia:
            continue

        try:
            contas.extend(_contas_de_outra_agencia(agencia["id"], usuario, id_agencia))
        except requests.RequestException:
            agencias_indisponiveis.append(agencia["id"])

    contas.sort(key=lambda conta: conta["id"])

    return jsonify(
        {
            "usuario": usuario,
            "contas": contas,
            "saldoTotal": sum(conta["saldo"] for conta in contas),
            "agenciasIndisponiveis": agencias_indisponiveis,
        }
    )
