from flask import jsonify, request

from services import repositorio_usuarios

TAMANHO_MINIMO_SENHA = 6


def criar_usuario():
    corpo = request.get_json(silent=True) or {}
    usuario = corpo.get("usuario")
    senha = corpo.get("senha")

    if not isinstance(usuario, str) or not usuario.strip():
        return jsonify({"erro": "O campo 'usuario' é obrigatório."}), 400
    if not isinstance(senha, str) or len(senha) < TAMANHO_MINIMO_SENHA:
        return (
            jsonify({"erro": f"A senha deve ter pelo menos {TAMANHO_MINIMO_SENHA} caracteres."}),
            400,
        )

    usuario = usuario.strip()

    if not repositorio_usuarios.criar_cliente(usuario, senha):
        return jsonify({"erro": "Já existe um usuário com esse nome."}), 409

    return jsonify({"usuario": usuario, "papel": repositorio_usuarios.PAPEL_CLIENTE}), 201
