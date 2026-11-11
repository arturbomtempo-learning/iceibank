import json
import os
from datetime import datetime

TIPOS_BULLY = (
    "ELEICAO_INICIADA",
    "ELEICAO_RECEBIDA",
    "TORNOU_LIDER",
    "LIDER_ANUNCIADO",
    "LIDER_NAO_RESPONDEU",
)

pasta_dados = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")
arquivos = [nome for nome in os.listdir(pasta_dados) if nome.endswith(".jsonl")]

eventos = []
for arquivo in arquivos:
    with open(os.path.join(pasta_dados, arquivo), encoding="utf-8") as conteudo:
        for linha in conteudo:
            linha = linha.strip()
            if linha:
                eventos.append(json.loads(linha))

eventos_bully = [evento for evento in eventos if evento["tipo"] in TIPOS_BULLY]
eventos_bully.sort(key=lambda evento: datetime.fromisoformat(evento["horaParede"]))


def formatar_detalhes(detalhes):
    return json.dumps(detalhes, ensure_ascii=False, separators=(",", ":"))


print("=== Histórico de eventos de eleição ===")

for evento in eventos_bully:
    print(
        f"({evento['horaParede']}) [{evento['agencia']}] {evento['tipo']}",
        formatar_detalhes(evento["detalhes"]),
    )

tornou_lider = [evento for evento in eventos_bully if evento["tipo"] == "TORNOU_LIDER"]
print("\n=== Linha do tempo de líderes ===")

for evento in tornou_lider:
    print(f"A partir de {evento['horaParede']}: Agência {evento['detalhes']['idAgencia']} é a líder")
