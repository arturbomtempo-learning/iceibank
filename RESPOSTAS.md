# Respostas

## Parte B - Relógio de Lamport e registro de eventos

### Questão 1

Se a agência simplesmente adotasse o timestamp recebido, ela poderia estar "voltando no tempo" em relação aos próprios eventos que já processou, o que quebraria a garantia central do algoritmo de que causa vem antes de consequência. Ao usar `max(contador_local, timestampRecebido) + 1`, a agência garante que o novo valor é sempre maior tanto que o último evento que ela mesma processou quanto que o evento que originou a mensagem recebida. Isso é o que faz o relógio de Lamport respeitar a relação de causalidade: como o crédito remoto em creditarRemoto só acontece depois do envio que o originou, seu timestamp precisa necessariamente ser maior que o timestamp daquele envio, e usar apenas o valor recebido não garantiria isso caso a agência que recebe já estivesse com um contador mais adiantado.

### Questão 2

O novo valor do contador da Agência 0 seria `max(10, 3) + 1 = 11`, ou seja, o contador simplesmente continua a partir do próprio valor local (10), ignorando na prática o timestamp mais baixo recebido, e soma 1. Isso mostra que uma agência que processa muitos eventos rapidamente (como a Agência 0 nesse exemplo) tem seu relógio lógico avançando bem mais rápido que o de agências mais lentas, e mensagens vindas de agências atrasadas praticamente não têm efeito sobre o contador de quem já está adiantado. Na prática, isso significa que o valor absoluto do timestamp de Lamport não indica "quanto tempo real passou", só a ordem relativa de causalidade entre eventos relacionados; duas agências com cargas de trabalho muito diferentes podem ter contadores bem distantes um do outro mesmo estando sincronizadas em termos de comunicação.
