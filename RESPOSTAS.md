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

### Questão 1

Na prática, isso significa que um timestamp de Lamport menor não é prova de causalidade, só uma condição necessária dela. Ao ver dois eventos com `timestamp(A) < timestamp(B)` na linha do tempo, existem duas possibilidades igualmente válidas: A pode ter causado B (por exemplo, um débito numa agência que gerou, via mensagem, o crédito remoto em outra) ou os dois podem ser totalmente independentes, e A só ficou com timestamp menor porque sua agência de origem processava menos eventos, ou processou aquele evento antes no tempo real, sem nenhuma relação com B. O relógio de Lamport, sozinho, não deixa claro em qual dos dois casos você está: para ter certeza, é preciso olhar o conteúdo dos eventos (por exemplo, ver que o `origemAgencia` de um crédito remoto bate com o débito correspondente) e não apenas o número do timestamp. Isso é justamente o que aconteceu nos pares que observei no passo 3: só dava para afirmar que o Lamport 2 da Agência 0 causou o Lamport 4 da Agência 1 porque os `detalhes` de ambos os eventos mostravam a mesma operação de transferência, não porque um timestamp era menor que o outro.

### Questão 2

Não, o relógio de Lamport sozinho não é suficiente para isso. Ele só garante a implicação em um sentido (A antes de B causalmente implica `timestamp(A) < timestamp(B)`), mas a volta não vale, então, ao ver dois timestamps diferentes, o sistema não tem como saber se está diante de uma relação de causa e efeito ou de dois eventos concorrentes que por acaso ficaram em ordens diferentes. No passo 3, isso ficou evidente: o par do Lamport 6 (concorrente) e o par dos Lamport 6 e 7, entre a Agência 0 e a Agência 2, tinham a mesma "forma" na linha do tempo de qualquer outro par de timestamps diferentes ou iguais - só dava para concluir que eram concorrentes analisando o contexto das operações e a hora de parede, não o timestamp de Lamport isoladamente. Um sistema bancário real, que precisa decidir com certeza se duas transferências concorrentes conflitam entre si (por exemplo, para detectar dupla gasto de saldo), não pode depender dessa análise manual e contextual. É exatamente essa lacuna que motiva o relógio vetorial: em vez de um único contador por processo, cada agência passa a manter um vetor com o contador de todas as agências, o que permite comparar dois timestamps e concluir de forma determinística se um aconteceu antes do outro ou se são genuinamente concorrentes, sem precisar inspecionar o conteúdo dos eventos.

## Parte F - Autenticação (JWT)

### Biblioteca escolhida

Usei a **PyJWT**, uma das duas opções que o próprio roteiro sugere pesquisar. Preferi ela em vez do suporte a JWT de algum framework maior (tipo `python-jose` combinado com FastAPI) porque o projeto já está em Flask puro e a PyJWT faz exatamente o necessário para este sprint: gerar e validar um token assinado, com verificação de expiração embutida, sem trazer nenhuma dependência extra de infraestrutura (banco de sessão, cache, etc.). Para o hash da senha usei `werkzeug.security` (pbkdf2), que já vem junto do Flask, então não precisei adicionar mais nenhuma biblioteca só para isso.

### Formato das credenciais de login

Decidi que o login **não fica vinculado a uma conta bancária específica**, e sim a um usuário genérico que representa quem está operando o sistema (o aluno testando pelo frontend), autenticado por usuário e senha em `POST /auth/login`. A senha fica guardada com hash (nunca em texto puro) em `config.py`.

O motivo principal é evitar uma dependência circular entre login e criação de conta: o requisito 3 da seção 11.1 exige token válido inclusive para **criar conta**. Se o login dependesse de uma conta já existente (id da conta + senha), seria impossível criar a primeira conta do sistema, porque criá-la já exigiria estar autenticado com uma conta que ainda não existe. Separando "quem está logado" de "qual conta está sendo operada", esse problema desaparece: o token apenas prova que quem está chamando a API é um usuário válido do sistema, e ele pode criar e operar contas livremente, do mesmo jeito que um funcionário de agência bancária real consegue abrir contas novas sem que a conta do cliente precise existir antes.

Uma consequência direta dessa escolha é que, nesta implementação, o token não amarra o chamador a nenhuma conta específica: qualquer usuário autenticado consegue operar qualquer conta de qualquer agência. Ou seja, esta parte cobre autenticação, mas não autorização por dono de conta.

### Tempo de expiração: 1 hora

Escolhi 1 hora de validade para o token de usuário. Um token eterno anularia todo o propósito da expiração (se ele vazasse, ficaria valendo para sempre), mas um tempo curto demais (tipo 1 ou 2 minutos) também não faz sentido para o cenário de uso real: pensando em uma pessoa efetivamente usando o frontend do ICEIBank para consultar saldo, fazer alguns depósitos e transferências ao longo de uma sessão de uso, ela provavelmente vai levar minutos fazendo isso, não segundos, e ficar sendo deslogada no meio de uma operação seria uma péssima experiência. Uma hora é também um padrão bastante comum no mercado para tokens de acesso de sessões web (é, por exemplo, o valor default de muitos serviços de autenticação como o Auth0), e equilibra bem os dois lados: dá tempo suficiente para uma sessão de uso completa, mas ainda limita bastante a janela de risco caso um token vaze, comparado a alternativas de vários dias.

### A chamada entre agências não usa o mesmo tipo de token do usuário

Decidi que a chamada de `creditar-remoto` (Parte D) **não deveria reutilizar o token do usuário** que iniciou a transferência, e sim receber um token próprio, de um tipo diferente, gerado pela agência de origem na hora da chamada.

O motivo é que o token do usuário representa uma sessão de uma pessoa específica, com validade de 1 hora e escopo pensado para chamadas vindas do frontend. Repassar esse mesmo token para outra agência espalharia essa credencial para fora do sistema que a emitiu, e se a chamada entre agências fosse interceptada (ou logada por engano em algum lugar), quem capturasse esse token ganharia acesso à sessão inteira da pessoa por até uma hora, podendo fazer qualquer operação em nome dela, não só a transferência em andamento. Isso aumenta desnecessariamente o estrago possível de um vazamento.

Por isso, implementei um segundo tipo de token, o token de **serviço**: a agência de origem gera um token novo, com o campo `"tipo": "servico"` no lugar de `"usuario"`, sem nenhuma informação de sessão de pessoa nenhuma, e com expiração de apenas 60 segundos (tempo mais que suficiente para uma chamada HTTP entre duas agências na mesma rede local, mas curto o bastante para não sobrar valor nenhum se vazar). A rota `creditar-remoto` só aceita tokens do tipo `servico`, e as rotas de conta só aceitam tokens do tipo `usuario` - um token de um tipo não serve na rota do outro, mesmo estando assinado com a mesma chave secreta. Essa separação segue o princípio de menor privilégio: cada token só pode ser usado exatamente para o que foi emitido, e não caso ele acabe indo parar em um lugar que não deveria.
