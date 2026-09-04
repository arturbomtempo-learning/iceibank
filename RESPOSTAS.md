# Respostas

## Parte B - Relógio de Lamport e registro de eventos

### Questão 1

Se a agência simplesmente adotasse o timestamp recebido, ela poderia estar "voltando no tempo" em relação aos próprios eventos que já processou, o que quebraria a garantia central do algoritmo de que causa vem antes de consequência. Ao usar `max(contador_local, timestampRecebido) + 1`, a agência garante que o novo valor é sempre maior tanto que o último evento que ela mesma processou quanto que o evento que originou a mensagem recebida. Isso é o que faz o relógio de Lamport respeitar a relação de causalidade: como o crédito remoto em creditarRemoto só acontece depois do envio que o originou, seu timestamp precisa necessariamente ser maior que o timestamp daquele envio, e usar apenas o valor recebido não garantiria isso caso a agência que recebe já estivesse com um contador mais adiantado.

### Questão 2

O novo valor do contador da Agência 0 seria `max(10, 3) + 1 = 11`, ou seja, o contador simplesmente continua a partir do próprio valor local (10), ignorando na prática o timestamp mais baixo recebido, e soma 1. Isso mostra que uma agência que processa muitos eventos rapidamente (como a Agência 0 nesse exemplo) tem seu relógio lógico avançando bem mais rápido que o de agências mais lentas, e mensagens vindas de agências atrasadas praticamente não têm efeito sobre o contador de quem já está adiantado. Na prática, isso significa que o valor absoluto do timestamp de Lamport não indica "quanto tempo real passou", só a ordem relativa de causalidade entre eventos relacionados; duas agências com cargas de trabalho muito diferentes podem ter contadores bem distantes um do outro mesmo estando sincronizadas em termos de comunicação.

## Parte D - Transferências

### Questão 1

Na transferência local, o débito e o crédito acontecem dentro do mesmo processo Node, usando a mesma instância do relógio de Lamport e o mesmo Map de contas em memória: os dois eventos são apenas chamadas sequenciais de `relogio.eventoLocal()` dentro da mesma função, sem nenhuma mensagem cruzando a rede. Como não há troca de mensagem entre processos diferentes, a ordem entre débito e crédito já é garantida naturalmente pela própria execução sequencial do código, sem precisar de nenhum mecanismo especial. Já na transferência entre agências, o débito acontece no processo da agência de origem e o crédito acontece em outro processo (outra agência, com seu próprio relógio de Lamport, rodando de forma independente), comunicados por uma chamada HTTP. É exatamente para esse caso que existem `aoEnviar()` e `aoReceber()`: o timestamp gerado no envio viaja dentro do corpo da mensagem, e a agência de destino usa esse valor para ajustar seu próprio contador, garantindo que o timestamp do crédito remoto fique sempre à frente do timestamp do débito que o causou, preservando a relação de causalidade entre dois processos distintos.

### Questão 2

Reproduzi a falha derrubando a Agência 1 e tentando transferir novamente da conta 0 para a conta 1. O log da Agência 0 (`agencia/data/eventos-agencia-0.jsonl`) mostra o débito sendo aplicado (`TRANSFERENCIA_DEBITO`, timestamp 7, valor 5) e logo em seguida a falha (`TRANSFERENCIA_FALHOU`, timestamp 9, com o erro `connect ECONNREFUSED ::1:4036`). Consultando o saldo da conta 0 depois do erro, o valor debitado não foi revertido: o saldo ficou 55 (100 inicial, menos 30 de uma transferência anterior, menos 10 de uma transferência local, menos os 5 dessa transferência que falhou). Isso significa que o sistema ficou em um estado inconsistente: o dinheiro saiu da conta de origem mas nunca chegou à conta de destino, quebrando a propriedade mais básica esperada de uma transferência bancária, que é ser atômica (ou as duas pontas da operação acontecem, ou nenhuma acontece). Na prática, a soma total de dinheiro registrado no sistema diminuiu, o que numa aplicação bancária real seria inaceitável.

### Questão 3

Uma forma é aplicar um **2PC (two-phase commit)**: antes de debitar de fato, a agência de origem envia uma mensagem de "preparar" para a agência de destino, perguntando se ela está pronta para receber o crédito (conta existe, está disponível etc.); só depois que a agência de destino confirma que está pronta é que a origem efetivamente debita e manda confirmar o crédito. Se a preparação falhar, nada é debitado, evitando o problema atual. Outra forma é usar o padrão **Saga com transação compensatória**: manter o fluxo atual (debita primeiro, depois tenta creditar remotamente), mas, se a chamada remota falhar, disparar automaticamente uma operação de estorno na própria conta de origem, devolvendo o valor debitado e registrando essa compensação no log, em vez de deixar a inconsistência apenas anotada sem nenhuma correção.
