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

todos_eventos.sort(key=lambda evento: evento["horaParede"])


def formatar_vetor(vetor):
    return json.dumps(vetor, separators=(",", ":"))


print("=== Linha do tempo (ordenada por hora de parede) ===")

for evento in todos_eventos:
    detalhes = json.dumps(evento["detalhes"], ensure_ascii=False)
    print(
        f"[{evento['agencia']}] vetor={formatar_vetor(evento['timestampVetorial'])} "
        f"{evento['tipo']} {detalhes}"
    )


def comparar_vetores(v1, v2):
    v1_menor_ou_igual = True
    v2_menor_ou_igual = True

    for posicao in range(len(v1)):
        if v1[posicao] > v2[posicao]:
            v1_menor_ou_igual = False
        if v2[posicao] > v1[posicao]:
            v2_menor_ou_igual = False

    if v1_menor_ou_igual and v2_menor_ou_igual:
        return "IGUAIS"
    if v1_menor_ou_igual:
        return "ANTES"
    if v2_menor_ou_igual:
        return "DEPOIS"

    return "CONCORRENTES"


print("\n=== Pares de eventos CONCORRENTES entre agências diferentes ===")
encontrou_concorrente = False

for i in range(len(todos_eventos)):
    for j in range(i + 1, len(todos_eventos)):
        e1 = todos_eventos[i]
        e2 = todos_eventos[j]

        if e1["agencia"] == e2["agencia"]:
            continue

        relacao = comparar_vetores(e1["timestampVetorial"], e2["timestampVetorial"])

        if relacao == "CONCORRENTES":
            encontrou_concorrente = True
            print(
                f"[{e1['agencia']}] {e1['tipo']} ({formatar_vetor(e1['timestampVetorial'])})"
                f"  x  [{e2['agencia']}] {e2['tipo']} ({formatar_vetor(e2['timestampVetorial'])})"
            )

if not encontrou_concorrente:
    print(
        "(nenhum par concorrente encontrado nesta execução, "
        "gere mais eventos em paralelo e rode de novo)"
    )
