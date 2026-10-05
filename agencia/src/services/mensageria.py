import json
import os
import threading
import time

import pika

URL_RABBITMQ = os.environ.get("RABBITMQ_URL")
EXCHANGE = "iceibank.eventos"
SEGUNDOS_PARA_RECONECTAR = 5

_lock_publicacao = threading.Lock()
_conexao_publicacao = None
_canal_publicacao = None


def _exigir_url():
    if not URL_RABBITMQ:
        raise RuntimeError(
            "Defina a variável de ambiente RABBITMQ_URL com a URL AMQP da sua "
            "instância CloudAMQP antes de iniciar."
        )


def _abrir_canal():
    _exigir_url()
    conexao = pika.BlockingConnection(pika.URLParameters(URL_RABBITMQ))
    canal = conexao.channel()
    canal.exchange_declare(exchange=EXCHANGE, exchange_type="topic", durable=True)
    return conexao, canal


def _descartar_canal_publicacao():
    global _conexao_publicacao, _canal_publicacao

    if _conexao_publicacao is not None and _conexao_publicacao.is_open:
        try:
            _conexao_publicacao.close()
        except pika.exceptions.AMQPError:
            pass

    _conexao_publicacao = None
    _canal_publicacao = None


def _obter_canal_publicacao():
    global _conexao_publicacao, _canal_publicacao

    if _canal_publicacao is None or _canal_publicacao.is_closed:
        _conexao_publicacao, _canal_publicacao = _abrir_canal()

    return _canal_publicacao


def publicar(routing_key, mensagem):
    corpo = json.dumps(mensagem, ensure_ascii=False).encode("utf-8")
    propriedades = pika.BasicProperties(delivery_mode=2, content_type="application/json")

    with _lock_publicacao:
        for tentativa in (1, 2):
            try:
                canal = _obter_canal_publicacao()
                canal.basic_publish(EXCHANGE, routing_key, corpo, propriedades)
                return
            except (pika.exceptions.AMQPError, OSError):
                _descartar_canal_publicacao()
                if tentativa == 2:
                    raise


def _criar_callback(ao_receber_mensagem):
    def callback(canal, metodo, propriedades, corpo):
        try:
            mensagem = json.loads(corpo.decode("utf-8"))
        except (UnicodeDecodeError, json.JSONDecodeError):
            print("[mensageria] mensagem descartada: corpo não é JSON válido", flush=True)
            canal.basic_ack(metodo.delivery_tag)
            return

        try:
            ao_receber_mensagem(mensagem)
        except Exception as erro:
            print(f"[mensageria] falha ao processar mensagem: {erro!r}", flush=True)

        canal.basic_ack(metodo.delivery_tag)

    return callback


def _consumir(id_agencia, ao_receber_mensagem):
    nome_fila = f"fila-agencia-{id_agencia}"
    routing_key = f"agencia.{id_agencia}.creditar"

    while True:
        try:
            conexao, canal = _abrir_canal()
            canal.queue_declare(queue=nome_fila, durable=True)
            canal.queue_bind(nome_fila, EXCHANGE, routing_key)
            canal.basic_qos(prefetch_count=1)
            canal.basic_consume(nome_fila, _criar_callback(ao_receber_mensagem))
            print(f"[mensageria] consumindo {nome_fila} com a chave {routing_key}", flush=True)
            canal.start_consuming()
        except (pika.exceptions.AMQPError, OSError) as erro:
            print(
                f"[mensageria] conexão perdida ({erro!r}), "
                f"nova tentativa em {SEGUNDOS_PARA_RECONECTAR}s",
                flush=True,
            )
            time.sleep(SEGUNDOS_PARA_RECONECTAR)


def assinar(id_agencia, ao_receber_mensagem):
    _exigir_url()

    thread = threading.Thread(
        target=_consumir,
        args=(id_agencia, ao_receber_mensagem),
        name=f"consumidor-agencia-{id_agencia}",
        daemon=True,
    )
    thread.start()
    return thread
