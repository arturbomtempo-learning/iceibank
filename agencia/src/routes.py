from flask import Blueprint

from controllers import contas_controller, transferencias_controller

rotas = Blueprint("rotas", __name__)

rotas.add_url_rule("/contas", view_func=contas_controller.criar_conta, methods=["POST"])
rotas.add_url_rule(
    "/contas/<int:id_conta>", view_func=contas_controller.consultar_saldo, methods=["GET"]
)
rotas.add_url_rule(
    "/contas/<int:id_conta>/depositar", view_func=contas_controller.depositar, methods=["POST"]
)
rotas.add_url_rule(
    "/contas/<int:id_conta>/sacar", view_func=contas_controller.sacar, methods=["POST"]
)

rotas.add_url_rule(
    "/transferencias", view_func=transferencias_controller.transferir, methods=["POST"]
)
rotas.add_url_rule(
    "/contas/<int:id_conta>/creditar-remoto",
    view_func=transferencias_controller.creditar_remoto,
    methods=["POST"],
)
