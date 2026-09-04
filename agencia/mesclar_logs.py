import json
import os

pasta_dados = os.path.join(os.path.dirname(os.path.abspath(__file__)), "data")
arquivos = [nome for nome in os.listdir(pasta_dados) if nome.endswith(".jsonl")]

todos_eventos = []
for arquivo in arquivos:
    with open(os.path.join(pasta_dados, arquivo), encoding="utf-8") as conteudo:
        for linha in conteudo:
            linha = linha.strip()
            if linha:
                todos_eventos.append(json.loads(linha))

todos_eventos.sort(key=lambda evento: evento["timestampLamport"])

print("=== Linha do tempo unificada (ordenada por relogio de Lamport) ===")

for evento in todos_eventos:
    detalhes = json.dumps(evento["detalhes"], ensure_ascii=False)
    print(
        f"[Lamport {evento['timestampLamport']}] ({evento['horaParede']}) "
        f"{evento['agencia']} - {evento['tipo']} {detalhes}"
    )
