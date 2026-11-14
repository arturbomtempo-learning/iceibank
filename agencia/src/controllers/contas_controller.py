from flask import current_app, jsonify, request

import config
from services import auth_service, repositorio_usuarios
from services.comparar_vetores import comparar_vetores
from services.relogio_vetorial import vetor_valido


def _estado():
    return (
        current_app.config["CONTAS"],
        current_app.config["RELOGIO"],
        current_app.config["REGISTRO"],
        current_app.config["ID_AGENCIA"],
    )


def _numero_valido(valor):
    return isinstance(valor, (int, float)) and not isinstance(valor, bool)


def _sem_permissao():
    return jsonify({"erro": "Você não tem permissão para operar esta conta."}), 403


def criar_conta():
    corpo = request.get_json(silent=True) or {}
    id_conta = corpo.get("id")
    nome_aluno = corpo.get("nomeAluno")
    dono = corpo.get("dono")
    saldo_inicial = corpo.get("saldoInicial", 0)

    contas, relogio, registro, id_agencia = _estado()

    if not isinstance(id_conta, int) or isinstance(id_conta, bool):
        return jsonify({"erro": "O campo 'id' é obrigatório e deve ser um número inteiro."}), 400
    if not _numero_valido(saldo_inicial):
        return jsonify({"erro": "O campo 'saldoInicial' deve ser um número."}), 400
    if not repositorio_usuarios.existe(dono):
        return jsonify({"erro": "O campo 'dono' deve ser um usuário existente."}), 400

    if config.agencia_responsavel(id_conta) != id_agencia:
        return jsonify({"erro": f"Conta {id_conta} não pertence a esta agência."}), 400
    if id_conta in contas:
        return jsonify({"erro": "Conta já existe."}), 409

    vetor = relogio.evento_local()
    contas[id_conta] = {
        "id": id_conta,
        "nomeAluno": nome_aluno,
        "dono": dono,
        "saldo": saldo_inicial,
    }
    registro.registrar(
        "CRIAR_CONTA",
        vetor,
        {"id": id_conta, "nomeAluno": nome_aluno, "dono": dono, "saldoInicial": saldo_inicial},
    )

    return jsonify(contas[id_conta]), 201


def consultar_saldo(id_conta):
    contas, relogio, _, _ = _estado()

    conta = contas.get(id_conta)
    if conta is None:
        return jsonify({"erro": "Conta não encontrada nesta agência."}), 404
    if not auth_service.pode_operar_conta(request.token_payload, conta):
        return _sem_permissao()

    return jsonify({**conta, "vetorAtual": relogio.obter_vetor_atual()})


def depositar(id_conta):
    corpo = request.get_json(silent=True) or {}
    valor = corpo.get("valor")

    contas, relogio, registro, _ = _estado()

    conta = contas.get(id_conta)
    if conta is None:
        return jsonify({"erro": "Conta não encontrada nesta agência."}), 404
    if not auth_service.pode_operar_conta(request.token_payload, conta):
        return _sem_permissao()
    if not _numero_valido(valor) or valor <= 0:
        return jsonify({"erro": "O campo 'valor' deve ser um número positivo."}), 400

    vetor = relogio.evento_local()
    conta["saldo"] += valor
    registro.registrar("DEPOSITO", vetor, {"id": id_conta, "valor": valor, "novoSaldo": conta["saldo"]})

    return jsonify(conta)


def sacar(id_conta):
    corpo = request.get_json(silent=True) or {}
    valor = corpo.get("valor")

    contas, relogio, registro, _ = _estado()

    conta = contas.get(id_conta)
    if conta is None:
        return jsonify({"erro": "Conta não encontrada nesta agência."}), 404
    if not auth_service.pode_operar_conta(request.token_payload, conta):
        return _sem_permissao()
    if not _numero_valido(valor) or valor <= 0:
        return jsonify({"erro": "O campo 'valor' deve ser um número positivo."}), 400
    if conta["saldo"] < valor:
        return jsonify({"erro": "Saldo insuficiente."}), 400

    vetor = relogio.evento_local()
    conta["saldo"] -= valor
    registro.registrar("SAQUE", vetor, {"id": id_conta, "valor": valor, "novoSaldo": conta["saldo"]})

    return jsonify(conta)


def sincronizar_operacao_pendente(id_conta):
    corpo = request.get_json(silent=True) or {}
    tipo = corpo.get("tipo")
    valor = corpo.get("valor")
    vetor_conhecido = corpo.get("vetorConhecido")

    contas, relogio, registro, _ = _estado()

    conta = contas.get(id_conta)
    if conta is None:
        return jsonify({"erro": "Conta não encontrada nesta agência."}), 404
    if not auth_service.pode_operar_conta(request.token_payload, conta):
        return _sem_permissao()
    if not vetor_valido(vetor_conhecido, config.NUMERO_AGENCIAS):
        return jsonify({"erro": "O campo 'vetorConhecido' deve ser um vetor válido."}), 400
    if not _numero_valido(valor) or valor <= 0:
        return jsonify({"erro": "O campo 'valor' deve ser um número positivo."}), 400

    vetor_atual = relogio.obter_vetor_atual()
    relacao = comparar_vetores(vetor_conhecido, vetor_atual)

    if relacao != "IGUAIS":
        return (
            jsonify(
                {
                    "erro": "Conflito detectado: o estado da conta mudou desde a última sincronização do app.",
                    "vetorConhecido": vetor_conhecido,
                    "vetorAtual": vetor_atual,
                    "contaAtual": conta,
                }
            ),
            409,
        )

    if tipo == "DEPOSITO":
        vetor = relogio.evento_local()
        conta["saldo"] += valor
    elif tipo == "SAQUE":
        if conta["saldo"] < valor:
            return jsonify({"erro": "Saldo insuficiente."}), 400
        vetor = relogio.evento_local()
        conta["saldo"] -= valor
    else:
        return jsonify({"erro": "Tipo de operação pendente não suportado."}), 400

    registro.registrar(
        "SINCRONIZACAO_OFFLINE", vetor, {"id": id_conta, "tipo": tipo, "valor": valor}
    )

    return jsonify(conta)
