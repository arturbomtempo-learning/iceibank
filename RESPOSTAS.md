# Respostas

## Funcionalidade adicional - Extrato consolidado

A funcionalidade adicional que escolhi implementar, exigida pela seção 2.1, é o **extrato consolidado**: um endpoint `GET /extrato` que reúne todas as contas do usuário logado **nas três agências** e devolve o saldo somado, em uma única chamada.

Escolhi essa entre as sugestões do roteiro porque ela é a que mais depende do que este sprint tem de característico. Consultar o saldo de uma conta é trivial, já que a agência responsável guarda tudo o que precisa em memória. Somar os saldos de contas espalhadas por agências diferentes, não: nenhuma agência sozinha tem essa informação, porque a partição (`id_conta % 3`) garante justamente que cada uma só conheça a sua fatia. O endpoint só consegue responder conversando com as outras duas pela rede.

O funcionamento é o seguinte. A agência que recebe a chamada separa as contas locais do usuário e, para cada uma das outras agências, faz uma requisição a uma rota interna nova, `GET /interno/contas/<usuario>`, protegida pelo mesmo **token de serviço** usado no `creditar-remoto`. Ou seja, o token de sessão da pessoa não é repassado adiante, mantendo a decisão de design da Parte F. No fim, junta tudo, ordena por número de conta e devolve a lista com o campo `saldoTotal`.

O contrato ficou assim. A requisição precisa apenas do token de usuário, e pode ser feita a qualquer uma das três agências:

```
GET /extrato
Authorization: Bearer <token>
```

```json
{
  "usuario": "bomtempo",
  "contas": [
    { "id": 6, "nomeAluno": "Artur Bomtempo", "dono": "bomtempo", "saldo": 2500, "agencia": 0 },
    { "id": 7, "nomeAluno": "Artur Bomtempo", "dono": "bomtempo", "saldo": 800, "agencia": 1 },
    { "id": 8, "nomeAluno": "Artur Bomtempo", "dono": "bomtempo", "saldo": 450, "agencia": 2 }
  ],
  "saldoTotal": 3750,
  "agenciasIndisponiveis": []
}
```

O campo `agencia` em cada conta mostra de qual partição ela veio, e o `saldoTotal` é a soma que nenhuma agência conseguiria calcular sozinha. Para efeito de comparação, uma consulta direta pela rota comum `GET /contas/6` só funciona na Agência 0: as outras duas respondem "Conta não encontrada nesta agência", justamente porque não conhecem contas fora da sua fatia. É esse contraste que aparece na evidência em `evidencias/sprint1/funcionalidade-adicional.png`.

Duas decisões que valem registro:

1. **A rota interna não confia no papel informado por quem chama.** Ela consulta o repositório de usuários para descobrir se aquele usuário é gerente ou correntista, e só então decide se devolve todas as contas da agência ou apenas as dele. Se aceitasse um campo enviado pela agência chamadora, bastaria forjar esse campo para ler as contas de qualquer pessoa.
2. **A indisponibilidade de uma agência não derruba o extrato.** Se uma das agências estiver fora do ar, o endpoint devolve o que conseguiu reunir e lista as agências que não responderam no campo `agenciasIndisponiveis`, e o frontend avisa que a soma está incompleta. Testei derrubando a Agência 2: o extrato continuou respondendo com as contas das Agências 0 e 1 e sinalizando a ausência da terceira.

No frontend, é esse endpoint que faz a tela inicial parecer um internet banking de verdade: a pessoa entra e já vê os cartões de todas as suas contas com o saldo, sem precisar digitar número de conta nenhum.

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

Não, o relógio de Lamport sozinho não é suficiente para isso. Ele só garante a implicação em um sentido (A antes de B causalmente implica `timestamp(A) < timestamp(B)`), mas a volta não vale, então, ao ver dois timestamps diferentes, o sistema não tem como saber se está diante de uma relação de causa e efeito ou de dois eventos concorrentes que por acaso ficaram em ordens diferentes. No passo 3, isso ficou evidente: o par do Lamport 6 (concorrente) e o par dos Lamport 6 e 7, entre a Agência 0 e a Agência 2, tinham a mesma "forma" na linha do tempo de qualquer outro par de timestamps diferentes ou iguais, e só dava para concluir que eram concorrentes analisando o contexto das operações e a hora de parede, não o timestamp de Lamport isoladamente. Um sistema bancário real, que precisa decidir com certeza se duas transferências concorrentes conflitam entre si (por exemplo, para detectar dupla gasto de saldo), não pode depender dessa análise manual e contextual. É exatamente essa lacuna que motiva o relógio vetorial: em vez de um único contador por processo, cada agência passa a manter um vetor com o contador de todas as agências, o que permite comparar dois timestamps e concluir de forma determinística se um aconteceu antes do outro ou se são genuinamente concorrentes, sem precisar inspecionar o conteúdo dos eventos.


## Parte F - Autenticação (JWT)

### Biblioteca escolhida

Usei a **PyJWT**, uma das opções que o próprio roteiro sugere. Ela faz exatamente o necessário para este sprint (gerar e validar um token assinado, com verificação de expiração embutida) sem trazer nenhuma dependência extra de infraestrutura, como banco de sessão ou cache. Para o hash das senhas usei `werkzeug.security`, que já vem junto do Flask.

### Formato das credenciais de login

O login é feito com **usuário e senha** em `POST /auth/login`, com a senha guardada em hash, nunca em texto puro. Cada usuário tem um **papel**: `admin`, que representa o gerente da agência, e `cliente`, que representa o correntista. As contas, por sua vez, ganharam um campo `dono`, que aponta para o usuário a quem aquela conta pertence.

Essa separação entre "usuário que faz login" e "conta bancária" resolve uma dependência circular do enunciado: o requisito 3 da seção 11.1 exige token válido inclusive para **criar conta**. Se o login dependesse de uma conta já existente, seria impossível criar a primeira conta do sistema, porque criá-la já exigiria um token vindo de uma conta que ainda não existe. Com papéis, isso deixa de ser um problema e o modelo ainda fica mais fiel ao mundo real, em que quem abre conta é o gerente, e não o próprio cliente.

O sistema nasce com um único usuário semeado, o `admin` (senha `admin1234`), que é o gerente. É ele quem cadastra os correntistas em `POST /usuarios` e depois abre as contas deles. Os usuários ficam em `agencia/data/usuarios.json`, um arquivo lido pelas três agências: as **contas** continuam particionadas, mas as **credenciais** são compartilhadas, senão um correntista cadastrado em uma agência não conseguiria entrar nem receber conta nas outras.

### Tempo de expiração: 1 hora

Um token eterno anularia o propósito da expiração, já que continuaria valendo para sempre caso vazasse. Por outro lado, um tempo muito curto atrapalharia o uso real: alguém consultando saldo e fazendo algumas operações pelo frontend leva minutos nisso, e ser deslogado no meio de uma operação seria uma péssima experiência. Uma hora é um valor bastante comum no mercado para tokens de acesso de sessões web e equilibra os dois lados, dando tempo para uma sessão completa e ainda assim limitando a janela de risco em caso de vazamento.

### A chamada entre agências não usa o mesmo tipo de token do usuário

A chamada de `creditar-remoto` (Parte D) **não reutiliza o token do usuário** que pediu a transferência. O token de usuário representa a sessão de uma pessoa e vale uma hora inteira, então repassá-lo para outra agência espalharia essa credencial para fora de onde ela foi emitida: se a chamada fosse interceptada, quem a capturasse teria acesso à sessão inteira daquela pessoa, e não apenas à transferência em andamento.

Por isso criei um segundo tipo de token, o de **serviço**: a agência de origem gera um token novo na hora da chamada, com `"tipo": "servico"` no lugar de `"usuario"`, sem identidade de pessoa nenhuma e com expiração de apenas 60 segundos. A rota `creditar-remoto` só aceita tokens de serviço, e as rotas de conta só aceitam tokens de usuário, então um token não serve na rota do outro mesmo estando assinado com a mesma chave. Isso segue o princípio de menor privilégio: cada token só vale para aquilo que foi emitido.

### Questão 1

Autenticação é responder "quem é você", e autorização é responder "o que você pode fazer, sendo quem você é". As duas acontecem nessa ordem: primeiro o sistema confirma a identidade de quem chamou a API, depois decide se essa identidade tem permissão para a operação pedida.

Minha implementação faz **as duas**, em funções separadas cujos nomes deixam a intenção explícita já na declaração das rotas:

1. **Autenticação**: `requer_autenticacao` valida a assinatura e a expiração do token. Token ausente, inválido ou expirado retorna **401**.
2. **Autorização por papel (RBAC)**: `requer_admin` protege a rota de abrir conta, que é operação de gerente. Um correntista autenticado que tente criar uma conta recebe **403**.
3. **Autorização por dono do recurso**: `auth_service.pode_operar_conta` compara o `sub` do token com o campo `dono` da conta nas rotas que leem ou movimentam uma conta específica. O gerente passa em qualquer conta, o correntista só nas dele, e a recusa é **403**.
4. **Separação do token interno**: `requer_servico` protege a rota `creditar-remoto`, que só aceita o token emitido por outra agência.

Respondendo ao exemplo do enunciado: não, um usuário autenticado **não** consegue sacar de uma conta que não é dele, a API responde `403 Forbidden`. O token está válido, o que falta é permissão, e é exatamente essa a diferença entre os dois conceitos. Vale notar que a transferência valida a posse apenas da conta de **origem**, já que receber dinheiro em conta de terceiro é justamente o objetivo de uma transferência.

Uma decisão consciente foi usar 401 e 403 com significados diferentes, como o próprio HTTP define: 401 é "não sei quem você é" e 403 é "sei quem você é, mas você não pode fazer isso". Outra foi guardar no `sub` do token o usuário, e não o id da conta: comparar o `sub` diretamente com o id da conta seria mais simples, mas amarraria cada pessoa a exatamente uma conta, o que não corresponde à realidade de um banco.

### Questão 2

Isso é possível porque o JWT é **autocontido e assinado digitalmente**: tudo o que é preciso para validá-lo (identidade, tipo e prazo de expiração) já vem dentro do próprio token, e a assinatura garante que ninguém alterou esse conteúdo depois que o servidor o emitiu. Para conferir a assinatura, o servidor só precisa da chave secreta que ele já tem em memória, sem perguntar a nenhum banco de dados se aquele token ainda vale.

Isso muda bastante a escalabilidade. Com sessões guardadas em memória no servidor, toda requisição precisaria chegar na mesma instância que criou a sessão, ou esse estado teria que ser compartilhado entre todas as instâncias por um banco ou um cache, o que adiciona uma dependência externa e mais um ponto de falha. Com JWT, qualquer instância que tenha a mesma chave valida o token sozinha, sem consultar nada, e é isso que permite as três agências funcionarem de forma independente sem que uma precise saber quem fez login na outra.

### Questão 3

Se a chave secreta vazasse, a segurança da autenticação inteira cairia por terra. Quem estivesse de posse dela conseguiria forjar tokens válidos sem saber a senha de ninguém: bastaria montar um payload com o papel desejado e um prazo de expiração no futuro, assinar com a chave vazada e operar qualquer conta em qualquer uma das três agências, já que todas compartilham a mesma chave. Pior ainda, essa mesma chave assina os tokens de serviço, então também seria possível forjar chamadas se passando por uma agência falando com a outra. A única forma de conter o estrago seria trocar a chave, o que invalida de uma vez todos os tokens já emitidos, inclusive os legítimos. É justamente por isso que ela nunca pode ir para o controle de versão e precisa vir de uma variável de ambiente ou de um cofre de segredos, como fiz com o arquivo `.env`, que não é versionado.

## Parte G - Frontend

### Questão 1

O token não é reenviado manualmente em lugar nenhum: isso acontece em um ponto único, o **interceptor de requisição** da instância de Axios que fica em `shared/services/api.ts`. Antes de qualquer requisição sair, ele lê a sessão guardada e, se ela existir, injeta o cabeçalho `Authorization: Bearer <token>`. Como todos os serviços do projeto usam essa mesma instância, nenhuma tela, store ou service precisa saber que o token existe: quem escreve uma chamada nova ganha a autenticação de graça, e não há risco de alguém esquecer de anexar o cabeçalho em uma rota.

O armazenamento em si fica isolado em `shared/services/token-storage.ts`, que é o único arquivo que toca no storage do navegador. Guardo a sessão no **`sessionStorage`**, e não no `localStorage`, porque assim o token morre junto com a aba, reduzindo o tempo em que ele fica disponível em uma máquina compartilhada. Junto do token gravo o instante de expiração, calculado a partir do `expiraEmSegundos` que o login devolve, e toda leitura confere esse prazo antes de entregar a sessão.

### Questão 2

A pessoa é avisada de forma explícita, não recebe um erro genérico. O tratamento acontece em duas camadas.

A primeira é preventiva e local: como o `token-storage` valida o prazo de expiração a cada leitura, uma sessão já vencida é descartada antes mesmo de a requisição sair, e a navegação é barrada pelo guard de rotas.

A segunda vale para o caso em que o token vence entre uma tela e outra, ou é recusado pelo servidor por qualquer motivo. O **interceptor de resposta** identifica o `401`, exibe um aviso com o título "Sessão encerrada" e o texto "Faça login novamente para continuar", limpa a sessão do storage e redireciona para a tela de login. Testei isso injetando um token realmente expirado no navegador: a aplicação mostrou o aviso e voltou para o login, sem deixar a pessoa presa em uma tela quebrada.

Um detalhe de implementação: o interceptor não importa o roteador nem a store de autenticação diretamente, porque isso criaria uma dependência circular. Em vez disso, ele expõe um `setUnauthorizedHandler`, e o `app/init.ts` registra ali a ação de deslogar e redirecionar quando a aplicação sobe.

### Questão 3

O padrão existe, mas não de forma tão literal quanto no backend, e vale ser honesto sobre isso. O Vue com Composition API não é um framework MVC clássico: ele é baseado em componentes, e o que mais se aproxima do modelo tradicional é o MVVM. Ainda assim, dá para mapear os três papéis:

- **Model**: os serviços em `shared/services/` (que definem os contratos com a API e os tipos como `Account` e `ConsolidatedStatement`) somados às stores do Pinia (`accounts.store`, `auth.store`, `agency.store`), que guardam o estado da aplicação e as regras de acesso a ele.
- **View**: os blocos `<template>` das páginas e os componentes reutilizáveis de `shared/components/`, que só recebem dados e emitem eventos, sem chamar a API diretamente.
- **Controller**: fica dividido entre as ações das stores e o `<script setup>` de cada página, que orquestra formulário, serviço e store. O `app/router` também assume parte desse papel, decidindo o que cada rota exige (autenticação, papel de gerente) antes de liberar a navegação.

O ponto mais misturado é justamente o Controller, que não mora em um arquivo próprio: ele está espalhado entre a store e o script da página. Na `TransferPage`, por exemplo, o script valida o formulário, chama o serviço, monta o resultado e manda a store recarregar os saldos, ou seja, faz trabalho de controller dentro do arquivo do componente. Foi uma escolha consciente por seguir a arquitetura por módulos definida no `INSTRUCTIONS.md` do projeto, que organiza o código por funcionalidade em vez de por camada, mas reconheço que isso afasta o frontend do MVC estrito. Quem segue o padrão à risca é o backend, onde `routes.py`, `controllers/` e `services/` separam as camadas de forma bem mais clara.

## Sprint 2: Parte B - Relógio vetorial

### Questão 1

O vetor cresce **linearmente** com o número de processos, porque guarda exatamente um contador por agência. Com 10 agências, cada mensagem passaria a carregar 10 inteiros em vez de 3, e o mesmo vale para cada linha gravada nos arquivos de evento, já que o `registro_eventos.py` serializa o vetor inteiro no campo `timestampVetorial`.

Medi o custo real serializando em JSON o corpo que o `transferencias_controller.py` envia para a rota `creditar-remoto` (`valor`, `timestampVetorial` e `origemAgencia`) e a linha correspondente no `.jsonl`:

| Agências | Corpo do `creditar-remoto` | Linha no log | Comparado ao Lamport |
| :---: | :---: | :---: | :---: |
| 3 | 65 B | 200 B | 1,2x |
| 10 | 86 B | 221 B | 1,5x |
| 50 | 206 B | 341 B | 3,7x |
| 100 | 356 B | 491 B | 6,4x |
| 1000 | 3056 B | 3191 B | 54,6x |

Com Lamport o mesmo corpo ocupa 56 B, porque o timestamp é um único inteiro. Subir de 3 para 10 agências custa 21 bytes por mensagem, o que é irrelevante diante do próprio cabeçalho HTTP e do token JWT que já viajam em cada chamada. Nessa escala, portanto, **não é um problema**: o ganho de poder determinar concorrência com certeza compensa com folga alguns bytes a mais.

O custo só passa a pesar quando o número de processos cresce de verdade. Com 1000 agências o corpo fica quase 55 vezes maior que o de Lamport, e aí o vetor deixa de ser um detalhe e passa a dominar o tamanho da mensagem. Pior que o tráfego é o armazenamento: como cada evento registrado carrega o vetor completo, o log cresce na mesma proporção, e um script de análise como o `mesclar_logs.py` precisa manter todos esses vetores em memória para comparar pares.

No código deste projeto, porém, o limite mais concreto não é o tamanho em bytes, e sim o fato de o número de agências ser **fixo e conhecido na inicialização**. O relógio é construído em `app.py` como `RelogioVetorial(id_agencia, config.NUMERO_AGENCIAS)`, e o `_vetor_valido` do `transferencias_controller.py` recusa qualquer vetor cujo comprimento seja diferente de `config.NUMERO_AGENCIAS`. Testei esse comportamento enviando para a Agência 1 um corpo com `"timestampVetorial": [1, 2]`, de duas posições: a resposta foi **HTTP 400**, e o relógio da agência não foi alterado, continuando no mesmo vetor anterior. Ou seja, crescer de 3 para 10 agências não é uma troca de número no `config.py`: as mensagens em trânsito com 3 posições passariam a ser rejeitadas, e todos os eventos já gravados ficariam com vetores de comprimento incompatível com os novos, inviabilizando a comparação entre eventos antigos e recentes. Em um sistema real com entrada e saída dinâmica de nós, é esse acoplamento a uma composição fixa de participantes, mais do que os bytes, que torna o relógio vetorial difícil de escalar.

### Questão 2

Dado `V1 = [3, 1, 0]` e `V2 = [3, 2, 0]`, **V1 aconteceu antes de V2**.

Comparando posição a posição, `V1[i] <= V2[i]` vale para todas as três posições, e os vetores são diferentes:

| Posição | V1 | V2 | `V1[i] <= V2[i]` |
| :---: | :---: | :---: | :---: |
| 0 (Agência 0) | 3 | 3 | sim (igual) |
| 1 (Agência 1) | 1 | 2 | sim |
| 2 (Agência 2) | 0 | 0 | sim (igual) |

Como nenhuma posição de V1 é maior que a de V2, e a posição 1 é estritamente menor, V1 domina em nenhum ponto e é dominado em um: essa é exatamente a definição de `V1 -> V2`, ou seja, existe relação de causa e efeito.

Reproduzi esse par com a própria classe `RelogioVetorial` do projeto para confirmar que ele corresponde a uma sequência possível do sistema. A Agência 0 registra dois eventos locais, chegando a `[2, 0, 0]`, e então chama `ao_enviar()`, que incrementa a própria posição e produz `[3, 0, 0]`, o vetor que viaja dentro da mensagem. A Agência 1, ainda zerada, executa `ao_receber([3, 0, 0])`: o `max` posição a posição dá `[3, 0, 0]` e o incremento da posição 1 resulta em `V1 = [3, 1, 0]`. Em seguida, um `evento_local()` na mesma Agência 1 produz `V2 = [3, 2, 0]`. Os dois eventos são consecutivos **dentro do mesmo processo**, o que torna a relação causal evidente: o segundo só pôde acontecer depois do primeiro.

Esse mesmo formato apareceu no servidor rodando de verdade. No teste que fiz com as três agências, a Agência 1 registrou `[0, 1, 0]` no `CRIAR_CONTA` e `[5, 2, 0]` no `TRANSFERENCIA_CREDITO_REMOTO`, e a comparação posição a posição classifica o par como **ANTES**, pelo mesmo motivo: um vetor é menor ou igual ao outro em todas as posições.

### Questão 3

Dado `V1 = [3, 1, 0]` e `V2 = [1, 3, 0]`, os eventos são **concorrentes**.

Aqui nenhum dos dois vetores domina o outro:

| Posição | V1 | V2 | Relação |
| :---: | :---: | :---: | :---: |
| 0 (Agência 0) | 3 | 1 | V1 **maior** |
| 1 (Agência 1) | 1 | 3 | V1 **menor** |
| 2 (Agência 2) | 0 | 0 | iguais |

Como `V1 <= V2` falha na posição 0 e `V2 <= V1` falha na posição 1, não vale nem `V1 -> V2` nem `V2 -> V1`. Isso significa que nenhum dos dois eventos teve como influenciar o outro: cada processo avançou por um caminho que o outro não conhecia. Lendo o conteúdo dos vetores, V1 pertence a um ponto da execução em que já se sabia de 3 eventos da Agência 0 mas de apenas 1 da Agência 1, enquanto V2 vem de um ponto em que se sabia de 3 eventos da Agência 1 mas de apenas 1 da Agência 0. Nenhum dos dois estados é alcançável a partir do outro.

Reproduzi os dois vetores com a classe real, em cenários independentes. No primeiro, a Agência 0 avança dois eventos locais e envia, e a Agência 1, ainda zerada, recebe: o resultado é `[3, 1, 0]`. No segundo, é a Agência 1 que avança dois eventos locais antes de receber uma mensagem de uma Agência 0 recém-iniciada, produzindo `[1, 3, 0]`. São duas histórias que não se cruzam, e é por isso que a comparação devolve `CONCORRENTES`.

Esse é justamente o cenário que o relógio de Lamport não conseguia distinguir, como anotei na Parte E do Sprint 1. No teste com o servidor real, gerei um depósito na Agência 2 sem nenhuma relação com a transferência que acontecia entre as Agências 0 e 1: o `TRANSFERENCIA_DEBITO` da Agência 0, com `[4, 0, 0]`, e o `DEPOSITO` da Agência 2, com `[0, 0, 2]`, saem como **CONCORRENTES** pela mesma regra desta questão, com cada vetor maior em uma posição e menor em outra. Dos 20 pares entre agências diferentes naquele log, 16 foram classificados como concorrentes e 4 como causalmente ordenados, e todos os 4 causais eram justamente os que envolviam o crédito remoto, ou seja, os únicos pares ligados por uma mensagem de verdade.
