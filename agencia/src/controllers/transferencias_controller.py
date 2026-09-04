import requests
from flask import current_app, jsonify, request

import config


def _estado():
    """Estado compartilhado da agência (equivalente ao req.app.locals do Express)."""
    return (
        current_app.config["CONTAS"],
        current_app.config["RELOGIO"],
        current_app.config["REGISTRO"],
        current_app.config["ID_AGENCIA"],
    )


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
    if conta_origem["saldo"] < valor:
        return jsonify({"erro": "Saldo insuficiente."}), 400

    agencia_destino = config.agencia_responsavel(id_destino)

    # O débito é sempre local, pois esta agência é a dona da conta de origem
    ts_debito = relogio.evento_local()
    conta_origem["saldo"] -= valor
    registro.registrar(
        "TRANSFERENCIA_DEBITO",
        ts_debito,
        {"idOrigem": id_origem, "idDestino": id_destino, "valor": valor},
    )

    if agencia_destino == id_agencia:
        # Caso simples: mesma agência, credita direto
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

    # Caso entre agências: chama a agência de destino diretamente via REST
    ts_envio = relogio.ao_enviar()
    url_destino = config.agencia_por_id(agencia_destino)["url"]

    try:
        resposta = requests.post(
            f"{url_destino}/contas/{id_destino}/creditar-remoto",
            json={
                "valor": valor,
                "timestampLamport": ts_envio,
                "origemAgencia": id_agencia,
            },
            timeout=5,
        )
        # O requests não levanta exceção para status de erro por padrão (diferente
        # do axios), então pedimos isso explicitamente com raise_for_status().
        resposta.raise_for_status()
        return jsonify({"mensagem": "Transferência concluída (entre agências)."})
    except requests.RequestException as erro:
        # LIMITAÇÃO CONHECIDA: se esta chamada falhar, o débito já aplicado acima
        # NÃO é revertido - o dinheiro "desaparece" temporariamente. Resolver isso
        # de forma correta (garantir atomicidade mesmo sob falha) é o assunto do
        # Sprint 4, com uma transação distribuída de verdade (2PC/Saga). Por
        # enquanto, só registramos a inconsistência no log.
        registro.registrar(
            "TRANSFERENCIA_FALHOU",
            relogio.evento_local(),
            {
                "idOrigem": id_origem,
                "idDestino": id_destino,
                "valor": valor,
                "erro": str(erro),
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

    # Ao RECEBER uma mensagem de outra agência, o relógio de Lamport é
    # atualizado com base no timestamp recebido - é a regra 3 do algoritmo.
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
