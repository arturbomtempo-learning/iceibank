# Respostas

## Parte B - Relógio de Lamport e registro de eventos

### Questão 1

Se a agência simplesmente adotasse o timestamp recebido, ela poderia estar "voltando no tempo" em relação aos próprios eventos que já processou, o que quebraria a garantia central do algoritmo de que causa vem antes de consequência. Ao usar `max(contador_local, timestampRecebido) + 1`, a agência garante que o novo valor é sempre maior tanto que o último evento que ela mesma processou quanto que o evento que originou a mensagem recebida. Isso é o que faz o relógio de Lamport respeitar a relação de causalidade: como o crédito remoto em creditarRemoto só acontece depois do envio que o originou, seu timestamp precisa necessariamente ser maior que o timestamp daquele envio, e usar apenas o valor recebido não garantiria isso caso a agência que recebe já estivesse com um contador mais adiantado.

### Questão 2

O novo valor do contador da Agência 0 seria `max(10, 3) + 1 = 11`, ou seja, o contador simplesmente continua a partir do próprio valor local (10), ignorando na prática o timestamp mais baixo recebido, e soma 1. Isso mostra que uma agência que processa muitos eventos rapidamente (como a Agência 0 nesse exemplo) tem seu relógio lógico avançando bem mais rápido que o de agências mais lentas, e mensagens vindas de agências atrasadas praticamente não têm efeito sobre o contador de quem já está adiantado. Na prática, isso significa que o valor absoluto do timestamp de Lamport não indica "quanto tempo real passou", só a ordem relativa de causalidade entre eventos relacionados; duas agências com cargas de trabalho muito diferentes podem ter contadores bem distantes um do outro mesmo estando sincronizadas em termos de comunicação.

## Parte D - Transferências

### Questão 1

Na transferência local, o débito e o crédito acontecem dentro do mesmo processo Flask, usando a mesma instância do relógio de Lamport e o mesmo dicionário de contas em memória: os dois eventos são apenas chamadas sequenciais de `relogio.evento_local()` dentro da mesma função, sem nenhuma mensagem cruzando a rede. Como não há troca de mensagem entre processos diferentes, a ordem entre débito e crédito já é garantida naturalmente pela própria execução sequencial do código, sem precisar de nenhum mecanismo especial. Já na transferência entre agências, o débito acontece no processo da agência de origem e o crédito acontece em outro processo (outra agência, com seu próprio relógio de Lamport, rodando de forma independente), comunicados por uma chamada HTTP. É exatamente para esse caso que existem `ao_enviar()` e `ao_receber()`: o timestamp gerado no envio viaja dentro do corpo da mensagem, e a agência de destino usa esse valor para ajustar seu próprio contador, garantindo que o timestamp do crédito remoto fique sempre à frente do timestamp do débito que o causou, preservando a relação de causalidade entre dois processos distintos.

### Questão 2

Reproduzi a falha derrubando a Agência 1 e tentando transferir novamente da conta 0 para a conta 1. O log da Agência 0 (`agencia/data/eventos-agencia-0.jsonl`) mostra o débito sendo aplicado (`TRANSFERENCIA_DEBITO`, timestamp 7, valor 5) e logo em seguida a falha (`TRANSFERENCIA_FALHOU`, timestamp 9, com o erro `Conexão recusada por http://localhost:4036`). Consultando o saldo da conta 0 depois do erro, o valor debitado não foi revertido: o saldo ficou 55 (100 inicial, menos 30 de uma transferência anterior, menos 10 de uma transferência local, menos os 5 dessa transferência que falhou). Isso significa que o sistema ficou em um estado inconsistente: o dinheiro saiu da conta de origem mas nunca chegou à conta de destino, quebrando a propriedade mais básica esperada de uma transferência bancária, que é ser atômica (ou as duas pontas da operação acontecem, ou nenhuma acontece). Na prática, a soma total de dinheiro registrado no sistema diminuiu, o que numa aplicação bancária real seria inaceitável.

### Questão 3

Uma forma é aplicar um **2PC (two-phase commit)**: antes de debitar de fato, a agência de origem envia uma mensagem de "preparar" para a agência de destino, perguntando se ela está pronta para receber o crédito (conta existe, está disponível etc.); só depois que a agência de destino confirma que está pronta é que a origem efetivamente debita e manda confirmar o crédito. Se a preparação falhar, nada é debitado, evitando o problema atual. Outra forma é usar o padrão **Saga com transação compensatória**: manter o fluxo atual (debita primeiro, depois tenta creditar remotamente), mas, se a chamada remota falhar, disparar automaticamente uma operação de estorno na própria conta de origem, devolvendo o valor debitado e registrando essa compensação no log, em vez de deixar a inconsistência apenas anotada sem nenhuma correção.

## Parte E - Linha do tempo unificada

### Observação sobre os eventos empatados (tarefa 10.2)

Rodando o `mesclar_logs.py` com as três agências, apareceram vários empates de `timestampLamport` entre agências diferentes. O par que escolhi analisar é o do **Lamport 6**: a Agência 0 registrou um `TRANSFERENCIA_CREDITO` (o crédito da transferência local da conta 0 para a conta 3) às 18:34:28.271470, e a Agência 2 registrou um `TRANSFERENCIA_DEBITO` (início da transferência da conta 2 para a conta 0) às 18:39:14.263725.

Esses dois eventos são **concorrentes, não causalmente relacionados**. Nenhuma mensagem foi trocada entre as duas agências antes deles: cada um é resultado de uma operação local independente, e nenhum dos dois teve como influenciar o outro. O empate no timestamp é justamente o sintoma disso, porque as duas agências evoluíram seus contadores separadamente, sem nada que ligasse uma à outra, e chegaram ao valor 6 por caminhos completamente distintos.

Comparando com o campo `horaParede`, a ordem **não bate** com a de Lamport. Os dois eventos empatam no relógio lógico, mas estão separados por quase 5 minutos de tempo real. Um caso ainda mais evidente aparece entre os Lamport 6 e 7: o evento de Lamport 6 da Agência 2 (18:39:14) aconteceu cerca de 4 minutos e meio **depois** do evento de Lamport 7 da Agência 0 (18:34:48), ou seja, a ordem por Lamport é o inverso da ordem real do relógio de parede. Isso não é um defeito do algoritmo, é o comportamento esperado: para eventos concorrentes, o relógio de Lamport simplesmente não promete nada sobre a ordem.

O contraste com um par realmente causal fica visível no mesmo log: o `TRANSFERENCIA_DEBITO` da Agência 0 (Lamport 2) e o `TRANSFERENCIA_CREDITO_REMOTO` da Agência 1 (Lamport 4) fazem parte da mesma transferência, e aí o relógio respeitou corretamente a ordem (2 < 4), porque existiu uma mensagem ligando um evento ao outro. O mesmo vale para a última linha da linha do tempo, em que a Agência 0 estava no contador 9 e, ao receber uma mensagem com timestamp 7 vinda da Agência 2, aplicou `max(9, 7) + 1 = 10`.

A conclusão é que timestamps iguais não significam "aconteceram ao mesmo tempo", e sim "não há relação de causa e efeito entre eles". A única garantia do relógio de Lamport é a de ida: se A causou B, então `timestamp(A) < timestamp(B)`. A volta não vale, e é por isso que a hora de parede pode contradizer a ordem lógica sem que nada esteja errado.
