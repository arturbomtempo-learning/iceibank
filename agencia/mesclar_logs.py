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


concorrentes = []
causais = []

for i in range(len(todos_eventos)):
    for j in range(i + 1, len(todos_eventos)):
        e1 = todos_eventos[i]
        e2 = todos_eventos[j]

        if e1["agencia"] == e2["agencia"]:
            continue

        relacao = comparar_vetores(e1["timestampVetorial"], e2["timestampVetorial"])

        if relacao == "CONCORRENTES":
            concorrentes.append((e1, e2))
        elif relacao == "ANTES":
            causais.append((e1, e2))
        elif relacao == "DEPOIS":
            causais.append((e2, e1))


def descrever(evento):
    return f"[{evento['agencia']}] {evento['tipo']} ({formatar_vetor(evento['timestampVetorial'])})"


print("\n=== Pares de eventos CONCORRENTES entre agências diferentes ===")

for e1, e2 in concorrentes:
    print(f"{descrever(e1)}  x  {descrever(e2)}")

if not concorrentes:
    print(
        "(nenhum par concorrente encontrado nesta execução, "
        "gere mais eventos em paralelo e rode de novo)"
    )

print("\n=== Pares CAUSALMENTE RELACIONADOS entre agências diferentes ===")

for anterior, posterior in causais:
    print(f"{descrever(anterior)}  ->  {descrever(posterior)}")

if not causais:
    print(
        "(nenhum par causal encontrado nesta execução, "
        "faça uma transferência entre agências e rode de novo)"
    )

print(
    f"\nTotal: {len(concorrentes) + len(causais)} pares entre agências diferentes, "
    f"{len(concorrentes)} concorrentes e {len(causais)} causalmente ordenados."
)
