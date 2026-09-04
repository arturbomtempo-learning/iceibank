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


def _numero_valido(valor):
    """Python é mais rígido que o JavaScript com tipos, então validamos antes de somar."""
    return isinstance(valor, (int, float)) and not isinstance(valor, bool)


def criar_conta():
    corpo = request.get_json(silent=True) or {}
    id_conta = corpo.get("id")
    nome_aluno = corpo.get("nomeAluno")
    saldo_inicial = corpo.get("saldoInicial", 0)

    contas, relogio, registro, id_agencia = _estado()

    if not isinstance(id_conta, int) or isinstance(id_conta, bool):
        return jsonify({"erro": "O campo 'id' é obrigatório e deve ser um número inteiro."}), 400
    if not _numero_valido(saldo_inicial):
        return jsonify({"erro": "O campo 'saldoInicial' deve ser um número."}), 400

    if config.agencia_responsavel(id_conta) != id_agencia:
        return jsonify({"erro": f"Conta {id_conta} não pertence a esta agência."}), 400
    if id_conta in contas:
        return jsonify({"erro": "Conta já existe."}), 409

    ts = relogio.evento_local()
    contas[id_conta] = {"id": id_conta, "nomeAluno": nome_aluno, "saldo": saldo_inicial}
    registro.registrar(
        "CRIAR_CONTA",
        ts,
        {"id": id_conta, "nomeAluno": nome_aluno, "saldoInicial": saldo_inicial},
    )

    return jsonify(contas[id_conta]), 201


def consultar_saldo(id_conta):
    contas, _, _, _ = _estado()

    conta = contas.get(id_conta)
    if conta is None:
        return jsonify({"erro": "Conta não encontrada nesta agência."}), 404

    return jsonify(conta)


def depositar(id_conta):
    corpo = request.get_json(silent=True) or {}
    valor = corpo.get("valor")

    contas, relogio, registro, _ = _estado()

    conta = contas.get(id_conta)
    if conta is None:
        return jsonify({"erro": "Conta não encontrada nesta agência."}), 404
    if not _numero_valido(valor) or valor <= 0:
        return jsonify({"erro": "O campo 'valor' deve ser um número positivo."}), 400

    ts = relogio.evento_local()
    conta["saldo"] += valor
    registro.registrar("DEPOSITO", ts, {"id": id_conta, "valor": valor, "novoSaldo": conta["saldo"]})

    return jsonify(conta)


def sacar(id_conta):
    corpo = request.get_json(silent=True) or {}
    valor = corpo.get("valor")

    contas, relogio, registro, _ = _estado()

    conta = contas.get(id_conta)
    if conta is None:
        return jsonify({"erro": "Conta não encontrada nesta agência."}), 404
    if not _numero_valido(valor) or valor <= 0:
        return jsonify({"erro": "O campo 'valor' deve ser um número positivo."}), 400
    if conta["saldo"] < valor:
        return jsonify({"erro": "Saldo insuficiente."}), 400

    ts = relogio.evento_local()
    conta["saldo"] -= valor
    registro.registrar("SAQUE", ts, {"id": id_conta, "valor": valor, "novoSaldo": conta["saldo"]})

    return jsonify(conta)
