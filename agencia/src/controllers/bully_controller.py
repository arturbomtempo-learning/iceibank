from flask import current_app, jsonify, request

import config
from services.relogio_vetorial import vetor_valido


def _id_agencia_valido(valor):
    ids = {agencia["id"] for agencia in config.AGENCIAS}
    return isinstance(valor, int) and not isinstance(valor, bool) and valor in ids


def _bully():
    return current_app.config["BULLY"]


def receber_eleicao():
    corpo = request.get_json(silent=True) or {}
    origem_id = corpo.get("origemId")
    vetor_envio = corpo.get("vetorEnvio")

    if not _id_agencia_valido(origem_id):
        return jsonify({"erro": "O campo 'origemId' deve ser o id de uma agência."}), 400
    if not vetor_valido(vetor_envio, config.NUMERO_AGENCIAS):
        return jsonify({"erro": "O campo 'vetorEnvio' deve ser um vetor válido."}), 400

    _bully().receber_eleicao(origem_id, vetor_envio)
    return jsonify({"mensagem": "Eleição recebida."})


def receber_coordenador():
    corpo = request.get_json(silent=True) or {}
    lider_id = corpo.get("liderId")
    vetor_envio = corpo.get("vetorEnvio")

    if not _id_agencia_valido(lider_id):
        return jsonify({"erro": "O campo 'liderId' deve ser o id de uma agência."}), 400
    if not vetor_valido(vetor_envio, config.NUMERO_AGENCIAS):
        return jsonify({"erro": "O campo 'vetorEnvio' deve ser um vetor válido."}), 400

    _bully().receber_coordenador(lider_id, vetor_envio)
    return jsonify({"mensagem": "Coordenador registrado."})


def consultar_lider():
    return jsonify(
        {
            "idAgencia": current_app.config["ID_AGENCIA"],
            "liderAtual": _bully().obter_lider_atual(),
        }
    )
