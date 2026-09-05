from flask import Blueprint

from controllers import (
    auth_controller,
    contas_controller,
    extrato_controller,
    transferencias_controller,
    usuarios_controller,
)
from middlewares.auth_middleware import requer_admin, requer_autenticacao, requer_servico

rotas = Blueprint("rotas", __name__)

rotas.add_url_rule("/auth/login", view_func=auth_controller.login, methods=["POST"])

rotas.add_url_rule(
    "/usuarios", view_func=requer_admin(usuarios_controller.criar_usuario), methods=["POST"]
)

rotas.add_url_rule(
    "/contas", view_func=requer_admin(contas_controller.criar_conta), methods=["POST"]
)

rotas.add_url_rule(
    "/contas/<int:id_conta>",
    view_func=requer_autenticacao(contas_controller.consultar_saldo),
    methods=["GET"],
)
rotas.add_url_rule(
    "/contas/<int:id_conta>/depositar",
    view_func=requer_autenticacao(contas_controller.depositar),
    methods=["POST"],
)
rotas.add_url_rule(
    "/contas/<int:id_conta>/sacar",
    view_func=requer_autenticacao(contas_controller.sacar),
    methods=["POST"],
)

rotas.add_url_rule(
    "/transferencias",
    view_func=requer_autenticacao(transferencias_controller.transferir),
    methods=["POST"],
)

rotas.add_url_rule(
    "/extrato", view_func=requer_autenticacao(extrato_controller.extrato_consolidado), methods=["GET"]
)

rotas.add_url_rule(
    "/contas/<int:id_conta>/creditar-remoto",
    view_func=requer_servico(transferencias_controller.creditar_remoto),
    methods=["POST"],
)
rotas.add_url_rule(
    "/interno/contas/<usuario>",
    view_func=requer_servico(extrato_controller.listar_contas_para_servico),
    methods=["GET"],
)
