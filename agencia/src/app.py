import os
import sys
from urllib.parse import urlparse

from flask import Flask

import config
from routes import rotas
from services.registro_eventos import RegistroEventos
from services.relogio_lamport import RelogioLamport


def criar_app(id_agencia):
    app = Flask(__name__)

    app.json.ensure_ascii = False

    app.config["ID_AGENCIA"] = id_agencia
    app.config["RELOGIO"] = RelogioLamport()
    app.config["REGISTRO"] = RegistroEventos(f"agencia-{id_agencia}")
    app.config["CONTAS"] = {}

    app.register_blueprint(rotas)

    return app


if __name__ == "__main__":
    id_agencia = int(os.environ.get("AGENCIA_ID", "0"))
    agencia_config = config.agencia_por_id(id_agencia)

    if agencia_config is None:
        print(f"Agência {id_agencia} não configurada em config.py")
        sys.exit(1)

    porta = urlparse(agencia_config["url"]).port

    app = criar_app(id_agencia)
    print(f"[Agência {id_agencia}] ouvindo na porta {porta}", flush=True)

    app.run(port=porta, threaded=True)
