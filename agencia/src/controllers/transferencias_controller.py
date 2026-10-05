from flask import current_app, jsonify, request

import config
from services import auth_service
from services.mensageria import publicar


def _estado():
    return (
        current_app.config["CONTAS"],
        current_app.config["RELOGIO"],
        current_app.config["REGISTRO"],
        current_app.config["ID_AGENCIA"],
    )


def _vetor_valido(vetor):
    return (
        isinstance(vetor, list)
        and len(vetor) == config.NUMERO_AGENCIAS
        and all(
            isinstance(posicao, int) and not isinstance(posicao, bool) and posicao >= 0
            for posicao in vetor
        )
    )


def _numero_positivo(valor):
    return isinstance(valor, (int, float)) and not isinstance(valor, bool) and valor > 0


def transferir():
    corpo = request.get_json(silent=True) or {}
    id_origem = corpo.get("idOrigem")
    id_destino = corpo.get("idDestino")
    valor = corpo.get("valor")

    contas, relogio, registro, id_agencia = _estado()

    if not isinstance(id_origem, int) or not isinstance(id_destino, int):
        return jsonify({"erro": "Os campos 'idOrigem' e 'idDestino' devem ser números inteiros."}), 400
    if not _numero_positivo(valor):
        return jsonify({"erro": "O campo 'valor' deve ser um número positivo."}), 400

    conta_origem = contas.get(id_origem)
    if conta_origem is None:
        return jsonify({"erro": "Conta de origem não encontrada nesta agência."}), 404
    if not auth_service.pode_operar_conta(request.token_payload, conta_origem):
        return jsonify({"erro": "Você não tem permissão para transferir desta conta."}), 403
    if conta_origem["saldo"] < valor:
        return jsonify({"erro": "Saldo insuficiente."}), 400

    agencia_destino = config.agencia_responsavel(id_destino)

    vetor_debito = relogio.evento_local()
    conta_origem["saldo"] -= valor
    registro.registrar(
        "TRANSFERENCIA_DEBITO",
        vetor_debito,
        {"idOrigem": id_origem, "idDestino": id_destino, "valor": valor},
    )

    if agencia_destino == id_agencia:
        conta_destino = contas.get(id_destino)

        if conta_destino is None:
            conta_origem["saldo"] += valor
            return jsonify({"erro": "Conta de destino não encontrada."}), 404

        vetor_credito = relogio.evento_local()

        conta_destino["saldo"] += valor
        registro.registrar(
            "TRANSFERENCIA_CREDITO",
            vetor_credito,
            {"idOrigem": id_origem, "idDestino": id_destino, "valor": valor},
        )
        return jsonify({"mensagem": "Transferência concluída (mesma agência)."})

    vetor_envio = relogio.ao_enviar()

    publicar(
        f"agencia.{agencia_destino}.creditar",
        {
            "idConta": id_destino,
            "idOrigem": id_origem,
            "valor": valor,
            "vetorEnvio": vetor_envio,
            "origemAgencia": id_agencia,
        },
    )

    return jsonify(
        {"mensagem": "Transferência publicada para a agência de destino (entrega assíncrona)."}
    )


def aplicar_credito_remoto(contas, relogio, registro, mensagem, id_agencia):
    id_conta = mensagem.get("idConta")
    valor = mensagem.get("valor")
    vetor_envio = mensagem.get("vetorEnvio")
    origem_agencia = mensagem.get("origemAgencia")

    if not isinstance(id_conta, int) or isinstance(id_conta, bool):
        return _descartar(registro, relogio, mensagem, "idConta ausente ou invalido")
    if not _numero_positivo(valor):
        return _descartar(registro, relogio, mensagem, "valor ausente ou invalido")
    if not _vetor_valido(vetor_envio):
        return _descartar(registro, relogio, mensagem, "vetorEnvio ausente ou invalido")

    vetor = relogio.ao_receber(vetor_envio)

    conta = contas.get(id_conta)
    if conta is None:
        registro.registrar(
            "CREDITO_REMOTO_FALHOU",
            vetor,
            {
                "idConta": id_conta,
                "valor": valor,
                "origemAgencia": origem_agencia,
                "motivo": "conta nao encontrada",
            },
        )
        _confirmar(relogio, id_agencia, mensagem, False, "conta nao encontrada")
        return

    conta["saldo"] += valor
    registro.registrar(
        "TRANSFERENCIA_CREDITO_REMOTO",
        vetor,
        {"idConta": id_conta, "valor": valor, "origemAgencia": origem_agencia},
    )
    _confirmar(relogio, id_agencia, mensagem, True, None)


def _confirmar(relogio, id_agencia, mensagem, aplicado, motivo):
    origem_agencia = mensagem.get("origemAgencia")
    id_origem = mensagem.get("idOrigem")

    if not isinstance(origem_agencia, int) or isinstance(origem_agencia, bool):
        return
    if not isinstance(id_origem, int) or isinstance(id_origem, bool):
        return
    if origem_agencia == id_agencia:
        return

    vetor_envio = relogio.ao_enviar()

    try:
        publicar(
            f"agencia.{origem_agencia}.confirmacao",
            {
                "idOrigem": id_origem,
                "idConta": mensagem.get("idConta"),
                "valor": mensagem.get("valor"),
                "aplicado": aplicado,
                "motivo": motivo,
                "vetorEnvio": vetor_envio,
                "agenciaConfirmadora": id_agencia,
            },
        )
    except Exception as erro:
        print(f"[mensageria] falha ao publicar confirmação: {erro!r}", flush=True)


def aplicar_confirmacao(contas, relogio, registro, mensagem):
    id_origem = mensagem.get("idOrigem")
    valor = mensagem.get("valor")
    vetor_envio = mensagem.get("vetorEnvio")
    aplicado = mensagem.get("aplicado")

    if not isinstance(id_origem, int) or isinstance(id_origem, bool):
        return _descartar(registro, relogio, mensagem, "idOrigem ausente ou invalido")
    if not _numero_positivo(valor):
        return _descartar(registro, relogio, mensagem, "valor ausente ou invalido")
    if not _vetor_valido(vetor_envio):
        return _descartar(registro, relogio, mensagem, "vetorEnvio ausente ou invalido")
    if not isinstance(aplicado, bool):
        return _descartar(registro, relogio, mensagem, "aplicado ausente ou invalido")

    vetor = relogio.ao_receber(vetor_envio)

    detalhes = {
        "idOrigem": id_origem,
        "idConta": mensagem.get("idConta"),
        "valor": valor,
        "agenciaConfirmadora": mensagem.get("agenciaConfirmadora"),
    }

    if aplicado:
        registro.registrar("TRANSFERENCIA_CONFIRMADA", vetor, detalhes)
        return

    conta = contas.get(id_origem)

    if conta is None:
        registro.registrar(
            "ESTORNO_FALHOU",
            vetor,
            {**detalhes, "motivo": "conta de origem nao encontrada"},
        )
        return

    conta["saldo"] += valor
    registro.registrar(
        "TRANSFERENCIA_ESTORNADA",
        vetor,
        {**detalhes, "motivo": mensagem.get("motivo"), "novoSaldo": conta["saldo"]},
    )


def _descartar(registro, relogio, mensagem, motivo):
    registro.registrar(
        "CREDITO_REMOTO_FALHOU",
        relogio.evento_local(),
        {"motivo": motivo, "mensagem": mensagem},
    )
