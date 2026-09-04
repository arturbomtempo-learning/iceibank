from flask import Blueprint

from controllers import auth_controller, contas_controller, transferencias_controller
from middlewares.auth_middleware import requer_token

rotas = Blueprint("rotas", __name__)

rotas.add_url_rule("/auth/login", view_func=auth_controller.login, methods=["POST"])

rotas.add_url_rule(
    "/contas", view_func=requer_token()(contas_controller.criar_conta), methods=["POST"]
)
rotas.add_url_rule(
    "/contas/<int:id_conta>",
    view_func=requer_token()(contas_controller.consultar_saldo),
    methods=["GET"],
)
rotas.add_url_rule(
    "/contas/<int:id_conta>/depositar",
    view_func=requer_token()(contas_controller.depositar),
    methods=["POST"],
)
rotas.add_url_rule(
    "/contas/<int:id_conta>/sacar",
    view_func=requer_token()(contas_controller.sacar),
    methods=["POST"],
)

rotas.add_url_rule(
    "/transferencias",
    view_func=requer_token()(transferencias_controller.transferir),
    methods=["POST"],
)
rotas.add_url_rule(
    "/contas/<int:id_conta>/creditar-remoto",
    view_func=requer_token(tipos_permitidos=("servico",))(transferencias_controller.creditar_remoto),
    methods=["POST"],
)
