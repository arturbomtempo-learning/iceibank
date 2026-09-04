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

    # Por padrão o Flask escapa acentos no JSON (â); desligamos isso para as
    # respostas saírem legíveis no terminal, como acontecia na versão Node.
    app.json.ensure_ascii = False

    # Equivalente ao app.locals do Express: estado compartilhado por todas as
    # requisições atendidas por este processo. As contas ficam em memória (um
    # dicionário), então somem quando a agência é reiniciada - é esperado neste sprint.
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

    # threaded=True é o padrão do servidor de desenvolvimento do Flask: por isso o
    # relógio de Lamport é protegido por um threading.Lock (ver relogio_lamport.py).
    app.run(port=porta, threaded=True)
