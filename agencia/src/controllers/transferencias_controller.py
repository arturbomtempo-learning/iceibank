import requests
from flask import current_app, jsonify, request

import config
from services import auth_service


def _estado():
    """Estado compartilhado da agência (equivalente ao req.app.locals do Express)."""
    return (
        current_app.config["CONTAS"],
        current_app.config["RELOGIO"],
        current_app.config["REGISTRO"],
        current_app.config["ID_AGENCIA"],
    )


def _resumir_erro(erro, url_destino):
    """Resume a exceção do requests, que por padrão gera um texto muito longo."""
    resposta = getattr(erro, "response", None)

    if resposta is not None:
        return f"{url_destino} respondeu HTTP {resposta.status_code}"
    if isinstance(erro, requests.Timeout):
        return f"Tempo esgotado ao contatar {url_destino}"
    if isinstance(erro, requests.ConnectionError):
        return f"Conexão recusada por {url_destino}"

    return f"{type(erro).__name__} ao contatar {url_destino}"


def transferir():
    corpo = request.get_json(silent=True) or {}
    id_origem = corpo.get("idOrigem")
    id_destino = corpo.get("idDestino")
    valor = corpo.get("valor")

    contas, relogio, registro, id_agencia = _estado()

    if not isinstance(id_origem, int) or not isinstance(id_destino, int):
        return jsonify({"erro": "Os campos 'idOrigem' e 'idDestino' devem ser números inteiros."}), 400
    if not isinstance(valor, (int, float)) or isinstance(valor, bool) or valor <= 0:
        return jsonify({"erro": "O campo 'valor' deve ser um número positivo."}), 400

    conta_origem = contas.get(id_origem)
    if conta_origem is None:
        return jsonify({"erro": "Conta de origem não encontrada nesta agência."}), 404
    if not auth_service.pode_operar_conta(request.token_payload, conta_origem):
        return jsonify({"erro": "Você não tem permissão para transferir desta conta."}), 403
    if conta_origem["saldo"] < valor:
        return jsonify({"erro": "Saldo insuficiente."}), 400

    agencia_destino = config.agencia_responsavel(id_destino)

    ts_debito = relogio.evento_local()
    conta_origem["saldo"] -= valor
    registro.registrar(
        "TRANSFERENCIA_DEBITO",
        ts_debito,
        {"idOrigem": id_origem, "idDestino": id_destino, "valor": valor},
    )

    if agencia_destino == id_agencia:
        conta_destino = contas.get(id_destino)

        if conta_destino is None:
            conta_origem["saldo"] += valor
            return jsonify({"erro": "Conta de destino não encontrada."}), 404

        ts_credito = relogio.evento_local()

        conta_destino["saldo"] += valor
        registro.registrar(
            "TRANSFERENCIA_CREDITO",
            ts_credito,
            {"idOrigem": id_origem, "idDestino": id_destino, "valor": valor},
        )
        return jsonify({"mensagem": "Transferência concluída (mesma agência)."})

    ts_envio = relogio.ao_enviar()
    url_destino = config.agencia_por_id(agencia_destino)["url"]

    token_servico = auth_service.gerar_token_servico(id_agencia)

    try:
        resposta = requests.post(
            f"{url_destino}/contas/{id_destino}/creditar-remoto",
            json={
                "valor": valor,
                "timestampLamport": ts_envio,
                "origemAgencia": id_agencia,
            },
            headers={"Authorization": f"Bearer {token_servico}"},
            timeout=5,
        )

        resposta.raise_for_status()
        return jsonify({"mensagem": "Transferência concluída (entre agências)."})
    except requests.RequestException as erro:
        registro.registrar(
            "TRANSFERENCIA_FALHOU",
            relogio.evento_local(),
            {
                "idOrigem": id_origem,
                "idDestino": id_destino,
                "valor": valor,
                "erro": _resumir_erro(erro, url_destino),
            },
        )
        return (
            jsonify(
                {
                    "erro": "Falha ao contatar agência de destino. Débito já aplicado - "
                    "inconsistência conhecida (ver Sprint 4)."
                }
            ),
            502,
        )


def creditar_remoto(id_conta):
    corpo = request.get_json(silent=True) or {}
    valor = corpo.get("valor")
    timestamp_lamport = corpo.get("timestampLamport")
    origem_agencia = corpo.get("origemAgencia")

    contas, relogio, registro, _ = _estado()

    ts = relogio.ao_receber(timestamp_lamport)

    conta = contas.get(id_conta)
    if conta is None:
        return jsonify({"erro": "Conta não encontrada nesta agência."}), 404

    conta["saldo"] += valor
    registro.registrar(
        "TRANSFERENCIA_CREDITO_REMOTO",
        ts,
        {"idConta": id_conta, "valor": valor, "origemAgencia": origem_agencia},
    )

    return jsonify({"mensagem": "Crédito remoto aplicado.", "saldoAtual": conta["saldo"]})
