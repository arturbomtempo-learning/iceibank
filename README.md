# ICEIBank

Um banco distribuído em três agências independentes, onde cada agência é um serviço REST autônomo, dono de uma partição das contas, que troca mensagens com as demais por um broker para concluir transferências e ordena os eventos do sistema com relógio vetorial.

![License](https://img.shields.io/badge/License-MIT-red?style=for-the-badge&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.14-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-3.1-000000?style=for-the-badge&logo=flask&logoColor=white)
![Vue](https://img.shields.io/badge/Vue.js-3.5-4FC08D?style=for-the-badge&logo=vuedotjs&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-6.0-3178C6?style=for-the-badge&logo=typescript&logoColor=white)
![Tailwind](https://img.shields.io/badge/Tailwind_CSS-4.3-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white)
![Flutter](https://img.shields.io/badge/Flutter-3.47-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.13-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![SQLite](https://img.shields.io/badge/SQLite-offline--first-003B57?style=for-the-badge&logo=sqlite&logoColor=white)
![JWT](https://img.shields.io/badge/Auth-JWT-D63AFF?style=for-the-badge&logo=jsonwebtokens&logoColor=white)
![RabbitMQ](https://img.shields.io/badge/RabbitMQ-Pub%2FSub-FF6600?style=for-the-badge&logo=rabbitmq&logoColor=white)
![Conceito](https://img.shields.io/badge/Sistemas_Distribuídos-Consenso_e_Relógio_Vetorial-555555?style=for-the-badge)
![Status](https://img.shields.io/badge/Sprint_3-Concluído-brightgreen?style=for-the-badge)
![Repo Size](https://img.shields.io/github/repo-size/arturbomtempo-learning/iceibank?style=for-the-badge)
![Last Commit](https://img.shields.io/github/last-commit/arturbomtempo-learning/iceibank?style=for-the-badge)

---

## 🚧 Status do Projeto

Sprints 1, 2 e 3 concluídas. As três agências rodam simultaneamente com partição de contas, relógio vetorial, transferências entre agências por mensageria assíncrona com RabbitMQ e autenticação e autorização via JWT. Desde o Sprint 3, elas também elegem uma líder entre si pelo algoritmo de Bully, detectam sozinhas a queda dela com heartbeat e failover automático, e aceitam a sincronização de operações feitas offline, detectando conflitos pelo relógio vetorial.

Dois clientes consomem a mesma API: o **frontend web** em Vue e o **app mobile** em Flutter, com o fluxo bancário completo, um painel que mostra a líder atual em tempo real e o modo offline-first, com armazenamento local, fila de operações pendentes e sincronização automática ao reconectar. Cada sprint tem sua funcionalidade adicional: o extrato consolidado no Sprint 1, a confirmação de entrega com estorno automático no Sprint 2 e o indicador de agências ativas no app do Sprint 3. As evidências de teste e as respostas conceituais de cada sprint estão registradas no repositório.

São quatro sprints ao longo do semestre: cada um parte do código do anterior e adiciona um novo conceito de Sistemas Distribuídos.

---

## 📚 Índice

- [ICEIBank](#iceibank)
    - [🚧 Status do Projeto](#-status-do-projeto)
    - [📚 Índice](#-índice)
    - [📝 Sobre o Projeto](#-sobre-o-projeto)
    - [🎬 Vídeo de Apresentação](#-vídeo-de-apresentação)
    - [✨ Funcionalidades Principais](#-funcionalidades-principais)
    - [⭐ Funcionalidades Adicionais](#-funcionalidades-adicionais)
        - [Sprint 1: extrato consolidado](#sprint-1-extrato-consolidado)
        - [Sprint 2: confirmação de entrega com estorno automático](#sprint-2-confirmação-de-entrega-com-estorno-automático)
        - [Sprint 3: indicador de agências ativas](#sprint-3-indicador-de-agências-ativas)
    - [🛠 Tecnologias Utilizadas](#-tecnologias-utilizadas)
    - [🏗 Arquitetura](#-arquitetura)
        - [Backend: as três agências](#backend-as-três-agências)
        - [Frontend: o internet banking](#frontend-o-internet-banking)
        - [Mobile: o app Flutter](#mobile-o-app-flutter)
        - [Sobre a pasta `agencia-express`](#sobre-a-pasta-agencia-express)
    - [⚙️ Instalação e Execução](#️-instalação-e-execução)
        - [Pré-requisitos](#pré-requisitos)
        - [📦 Passo 1: clonar e preparar o backend](#-passo-1-clonar-e-preparar-o-backend)
        - [🏦 Passo 2: subir as três agências](#-passo-2-subir-as-três-agências)
        - [💻 Passo 3: subir o frontend](#-passo-3-subir-o-frontend)
        - [🛑 Como parar](#-como-parar)
        - [🔑 Passo 4: primeiro acesso](#-passo-4-primeiro-acesso)
        - [📱 Passo 5: rodar o app mobile](#-passo-5-rodar-o-app-mobile)
        - [🕒 Linha do tempo unificada](#-linha-do-tempo-unificada)
        - [🧯 Problemas comuns](#-problemas-comuns)
    - [🔌 Endpoints da API](#-endpoints-da-api)
    - [📂 Estrutura de Pastas](#-estrutura-de-pastas)
    - [🖼️ Evidências](#️-evidências)
        - [Sprint 1](#sprint-1)
        - [Sprint 2](#sprint-2)
        - [Sprint 3](#sprint-3)
    - [📖 Referências](#-referências)
    - [🤖 Uso Responsável de IA](#-uso-responsável-de-ia)
    - [🙏 Agradecimentos](#-agradecimentos)
    - [👤 Autor](#-autor)
    - [📄 Licença](#-licença)

---

## 📝 Sobre o Projeto

O **ICEIBank** é um banco simplificado dividido em agências, desenvolvido como projeto da disciplina de Laboratório de Desenvolvimento de Aplicações Móveis e Distribuídas. A ideia central não é o domínio bancário em si, mas usá-lo como cenário para aplicar conceitos de Sistemas Distribuídos em um sistema que realmente funciona.

O ponto de partida é uma decisão de arquitetura: as contas são **particionadas**, não replicadas. Cada conta pertence a exatamente uma agência, determinada pela regra `número_da_conta % 3`. A conta 0 vive na Agência 0, a conta 1 na Agência 1, a conta 2 na Agência 2, a conta 3 volta para a Agência 0, e assim por diante. Nenhuma agência conhece as contas das outras.

Essa escolha é o que dá sentido a tudo o mais. Uma transferência entre contas da mesma agência é resolvida internamente, na memória do processo. Já uma transferência entre agências exige que a agência de origem debite localmente e publique uma mensagem para a agência de destino creditar. Duas máquinas diferentes, dois relógios diferentes, uma operação só.

É aí que entram os conceitos centrais do projeto. O Sprint 1 trouxe o **relógio lógico de Lamport**, e o Sprint 2 o substituiu pelo **relógio vetorial**: em vez de um contador único por agência, cada uma passa a manter um contador por agência, o que permite afirmar com certeza se dois eventos são causalmente relacionados ou concorrentes, distinção que o Lamport não conseguia fazer. Todo evento do sistema é registrado em log com seu timestamp vetorial, e um script mescla os logs das três agências em uma linha do tempo única, apontando os pares concorrentes.

O projeto também expõe, de forma deliberada, as limitações de cada etapa. No Sprint 1, se a agência de destino caísse no meio de uma transferência, o débito já aplicado não era revertido. A mensageria do Sprint 2 resolveu a entrega, porque a mensagem fica retida na fila e é entregue quando a agência volta, e a confirmação de entrega resolveu o crédito que falha no destino, porque a origem recebe o desfecho e devolve o valor. O que ainda falta é **atomicidade**: o estorno é uma compensação posterior, não uma transação única, não há controle de idempotência para mensagens reentregues, e se a publicação no broker falhar depois do débito, o valor fica debitado sem chegar ao destino. Essas lacunas não são escondidas, elas são registradas no log e documentadas, porque resolvê-las de verdade é o tema do Sprint 4, com transações distribuídas.

O Sprint 3 segue a mesma linha. A líder eleita pelo Bully ainda é só **informativa**: nenhuma operação passa por ela, papel que ela assume no Sprint 4, coordenando o 2PC. E a detecção de conflito offline-first é propositalmente simples: como o vetor é da agência, e não da conta, qualquer evento na agência conta como mudança, inclusive em outra conta. O app não resolve o conflito sozinho: mostra o saldo real e deixa a pessoa decidir.

| Sprint | Conceito de Sistemas Distribuídos             |   Situação   |
| :----: | --------------------------------------------- | :----------: |
| **1**  | **Relógio lógico de Lamport**                 | ✅ Concluído |
| **2**  | **Relógio vetorial e mensageria**             | ✅ Concluído |
| **3**  | **Consenso (eleição de líder) e app Flutter** | ✅ Concluído |
|   4    | Transações distribuídas (2PC/Saga)            |  Planejado   |

---

## 🎬 Vídeo de Apresentação

Como parte da entrega, foi gravado um vídeo apresentando o projeto em funcionamento:

**▶️ [Assistir à apresentação do Sprint 1](https://youtu.be/fpBiZ1JiXc8)**

---

## ✨ Funcionalidades Principais

**Partição de contas entre agências.** Cada conta pertence a uma única agência, calculada por `id % 3`. Uma agência recusa explicitamente operar contas que não são suas, respondendo com erro em vez de fingir que a conta não existe.

**Relógio vetorial.** Implementa as três regras do algoritmo: incremento da própria posição a cada evento local, incremento e envio do vetor junto da mensagem, e `max` posição a posição seguido de incremento da própria posição ao receber. O vetor é protegido por lock, já que o servidor atende requisições em múltiplas threads.

**Mensageria entre agências.** A transferência entre agências deixou de ser uma chamada HTTP direta e passa por uma exchange `topic` do RabbitMQ chamada `iceibank.eventos`, com uma fila durável por agência e routing key `agencia.<id>.creditar`. A agência de origem publica e segue adiante, sem precisar saber se o destino está no ar, e o consumidor roda em uma thread separada do servidor HTTP.

**Confirmação de entrega com estorno automático.** Depois de processar um crédito remoto, a agência de destino publica o desfecho em `agencia.<origem>.confirmacao`, e a origem consome essa resposta. Quando o crédito falha, por exemplo porque a conta de destino não existe, a origem devolve o valor à conta de origem e registra `TRANSFERENCIA_ESTORNADA`, aplicando o padrão Saga com transação compensatória. É o que impede o dinheiro de desaparecer quando a outra ponta não consegue concluir. Detalhes em [Funcionalidades Adicionais](#sprint-2-confirmação-de-entrega-com-estorno-automático).

**Registro de eventos auditável.** Toda operação gera uma linha em `data/eventos-agencia-N.jsonl` com o tipo do evento, o timestamp vetorial, a hora de parede e os detalhes. Dezesseis tipos de evento são registrados, das operações bancárias, de `CRIAR_CONTA` a `TRANSFERENCIA_ESTORNADA`, às etapas da eleição, de `ELEICAO_INICIADA` a `LIDER_NAO_RESPONDEU`, além de `SINCRONIZACAO_OFFLINE`.

**Eleição de líder pelo algoritmo de Bully.** Ao subir, cada agência envia uma mensagem de eleição às agências de id maior. Se nenhuma responder, ela se declara líder e anuncia o resultado a todas; se alguma responder, essa assume a eleição. O resultado é sempre a agência de maior id entre as ativas, e toda mensagem carrega o vetor do relógio vetorial, então a eleição também aparece na linha do tempo causal. A cada 3 segundos, cada agência faz um heartbeat: consulta a líder que conhece e, se ela não responder em 1 segundo, registra `LIDER_NAO_RESPONDEU`, esquece a líder antiga e inicia uma nova eleição. Assim a queda da líder é resolvida sem intervenção manual, e uma agência que volta ao ar com id maior retoma a liderança. Por enquanto a líder é só informativa: no Sprint 4 ela passa a coordenar as transações distribuídas.

**Linha do tempo causal.** O script `mesclar_logs.py` lê os logs das três agências, monta uma linha do tempo única por hora de parede e compara os vetores par a par, listando explicitamente os eventos concorrentes e separando-os dos causalmente ordenados.

**Sincronização offline-first com detecção de conflito.** A consulta de saldo devolve também o vetor atual da agência, que o app guarda junto da conta. Uma operação feita offline volta depois por `POST /contas/<id>/sincronizar`, levando esse vetor como `vetorConhecido`. A agência compara os dois vetores com a mesma lógica do `mesclar_logs.py`: se forem iguais, nada mudou desde a última leitura e o depósito ou saque é aplicado, registrando `SINCRONIZACAO_OFFLINE`. Se o vetor da agência avançou, ela não aplica a operação às cegas e responde `409` com o estado atual da conta e o vetor novo, para o app decidir o que fazer.

**API REST em arquitetura MVC.** Rotas, controllers e services separados, com CRUD de contas, depósito, saque e transferências.

**Transferências locais e entre agências.** O frontend não precisa saber a diferença: envia origem, destino e valor, e o backend decide se resolve internamente ou se publica a operação para a agência de destino. A resposta informa qual dos dois casos ocorreu.

**Resiliência a agências fora do ar.** Se a agência de destino estiver desligada, a transferência não falha: a mensagem fica retida na fila durável e é entregue quando ela volta. Falhas que não podem ser resolvidas, como um estorno para uma conta que já não existe, geram eventos próprios (`CREDITO_REMOTO_FALHOU`, `ESTORNO_FALHOU`), deixando o problema visível em vez de mascarado.

**Autenticação com JWT.** Login com usuário e senha (guardada em hash), token assinado com expiração de uma hora, e todas as rotas de conta protegidas. Token ausente, inválido ou expirado é recusado com HTTP 401.

**Autorização em três camadas.** Além de autenticar, o sistema verifica permissões: papel de gerente para abrir contas e cadastrar correntistas, posse do recurso para movimentar uma conta específica, e um tipo de token separado para as chamadas internas entre agências. Falhas de permissão respondem com HTTP 403, distinguindo "não sei quem você é" de "sei quem você é, mas você não pode".

**Token de serviço para comunicação interna.** A chamada HTTP entre agências, usada pelo extrato consolidado, não reutiliza o token de sessão da pessoa. A agência que chama gera um token próprio, de curtíssima duração e sem identidade de usuário, seguindo o princípio de menor privilégio.

**Frontend web completo.** Internet banking em Vue com login, visão consolidada de saldos, depósito, saque, transferências, cadastro de correntistas e abertura de contas, com tratamento visível de todos os erros retornados pela API. Inclui página inicial pública, tema claro e escuro e uma página de identidade visual (`/identidade-visual`) que documenta o design system: logo, cores, tipografia, mascote, componentes e regras de escrita.

**SEO e compartilhamento.** Cada página tem título, descrição e link canônico próprios, atualizados a cada navegação. As páginas públicas são indexáveis e as autenticadas saem com `noindex`. O build gera o HTML de cada rota já com as tags certas, além de `robots.txt`, `sitemap.xml`, imagem de prévia para redes sociais e ícones do app.

**Roteamento automático de agência.** O frontend e o app descobrem sozinhos qual agência atende cada conta e enviam a requisição para o endereço certo, sem que a pessoa precise escolher. Um controle manual permite fixar uma agência específica para demonstrar o comportamento da partição.

**App mobile em Flutter.** Cliente nativo com visual iOS (Cupertino), que roda no iPhone e no Android: login com JWT guardado no Keychain e no Keystore, saldo, depósito, saque, transferência local e entre agências, cadastro de correntistas e abertura de contas pelo gerente, e tratamento visível dos erros da API, inclusive o aviso de sessão expirada. Se uma agência cai, o app tenta as outras antes de desistir.

**Painel de liderança em tempo real.** A home do app mostra qual agência é a líder, consultando `GET /bully/lider` a cada 3 segundos, sem que a pessoa precise atualizar a tela. Quando a líder muda, o painel anuncia a troca com o horário. ⭐ Com o indicador de agências ativas, ele também mostra o estado de cada agência e se elas concordam sobre a líder.

**Modo offline-first no app.** O saldo e o vetor de cada conta ficam guardados em SQLite, e a home continua funcionando sem conexão, com o último saldo conhecido. Um depósito ou saque feito sem conexão vai para uma fila local, com o vetor conhecido, e aparece na hora como saldo provisório. Quando a agência volta, o app sincroniza sozinho. Se a agência recusar com `409`, o app mostra o saldo real e pergunta à pessoa se aplica a operação mesmo assim ou a descarta.

**Aparência ajustável.** O app segue o tema do aparelho por padrão, e a pessoa pode fixar o tema claro ou escuro só para ele, numa tela de ajustes. A escolha fica salva.

---

## ⭐ Funcionalidades Adicionais

Além do escopo obrigatório, a seção 2.1 de cada roteiro exige pelo menos uma funcionalidade autoral por sprint.

### Sprint 1: extrato consolidado

A funcionalidade escolhida foi o **extrato consolidado**: um endpoint `GET /extrato` que reúne todas as contas do usuário logado nas três agências e devolve o saldo somado em uma única chamada.

A escolha foi deliberada. Consultar o saldo de uma conta é trivial, porque a agência responsável guarda tudo o que precisa em memória. Somar saldos de contas espalhadas por agências diferentes, não: a partição garante que nenhuma agência sozinha tenha essa informação. O endpoint só consegue responder conversando com as outras duas pela rede, o que faz dele uma funcionalidade que depende diretamente do que esta sprint tem de característico.

**Como funciona.** A agência que recebe a chamada separa as contas locais do usuário e, para cada uma das outras agências, faz uma requisição à rota interna `GET /interno/contas/<usuario>`, protegida pelo mesmo token de serviço usado no crédito remoto. O token de sessão da pessoa nunca é repassado adiante. No fim, junta tudo, ordena por número de conta e devolve com o campo `saldoTotal`.

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

Duas decisões de projeto que valem destaque:

1. **A rota interna não confia no papel informado por quem chama.** Ela consulta o repositório de usuários para descobrir se aquele usuário é gerente ou correntista. Se aceitasse um campo enviado pela agência chamadora, bastaria forjá-lo para ler as contas de qualquer pessoa.
2. **A queda de uma agência não derruba o extrato.** Se uma delas estiver fora do ar, o endpoint devolve o que conseguiu reunir e lista as ausentes no campo `agenciasIndisponiveis`, e o frontend avisa que a soma está incompleta.

É esse endpoint que faz a tela inicial funcionar como um internet banking de verdade: a pessoa entra e já vê os cartões de todas as suas contas, sem digitar número de conta nenhum. A documentação completa está no [`RESPOSTAS.md`](RESPOSTAS.md).

### Sprint 2: confirmação de entrega com estorno automático

Com a mensageria, a agência de origem passou a debitar, publicar e nunca mais saber o que aconteceu do outro lado. Se o crédito falhasse no destino, por exemplo porque a conta não existe, o dinheiro simplesmente sumia e só restava uma linha de log na outra agência. A **confirmação de entrega** fecha esse ciclo.

**Como funciona.** Depois de processar o crédito, com sucesso ou não, a agência de destino publica o desfecho em `agencia.<origem>.confirmacao`. A origem consome essa mensagem e decide:

- **Crédito aplicado:** registra `TRANSFERENCIA_CONFIRMADA` e encerra o ciclo.
- **Crédito recusado:** devolve o valor à conta de origem e registra `TRANSFERENCIA_ESTORNADA`, com o motivo informado pelo destino.
- **Conta de origem inexistente:** registra `ESTORNO_FALHOU`, deixando a inconsistência explícita em vez de silenciosa.

```
[agencia-0] TRANSFERENCIA_DEBITO      [5, 3, 0]
[agencia-1] CREDITO_REMOTO_FALHOU     [6, 4, 0]  motivo: conta nao encontrada
[agencia-0] TRANSFERENCIA_ESTORNADA   [7, 5, 0]  motivo: conta nao encontrada
```

É o padrão **Saga com transação compensatória**, apontado no Sprint 1 como alternativa ao 2PC e agora implementado de fato. A soma de dinheiro do sistema é preservada, e o vetor mostra que o estorno é causalmente posterior à falha: o `5` na posição da Agência 1 só pode ter chegado à Agência 0 dentro da mensagem de confirmação.

A infraestrutura não precisou de fila nova: a chave de confirmação é vinculada à mesma `fila-agencia-<id>` que já existia. A limitação conhecida é a falta de idempotência, já que uma confirmação negativa reentregue pelo broker aplicaria o estorno duas vezes. A análise completa está no [`RESPOSTAS.md`](RESPOSTAS.md).

### Sprint 3: indicador de agências ativas

O painel de liderança do app mostrava a líder segundo uma única agência. O **indicador de agências ativas** consulta as 3 em paralelo a cada ciclo e mostra, para cada uma, se está no ar, o tempo de resposta e qual líder ela reconhece.

**Como funciona.** A líder em destaque continua vindo da primeira agência que responde, na ordem fixa 0 → 1 → 2. Uma faixa abaixo das agências classifica o estado da rede:

- **Consenso:** todas as agências no ar reconhecem a mesma líder.
- **Líder que não responde:** as agências ainda apontam para uma líder que caiu, na janela antes do próximo heartbeat.
- **Divergência:** agências no ar apontam para líderes diferentes, e a que discorda fica destacada.
- **Eleição em andamento:** as agências respondem, mas ainda sem líder.

Cada agência que responde emite um pulso no próprio nó, e as ligações entre agências ativas ficam verdes. É a forma de ver o consenso do Bully acontecendo, inclusive o momento em que ele ainda não existe. A análise completa está no [`RESPOSTAS.md`](RESPOSTAS.md).

---

## 🛠 Tecnologias Utilizadas

**Backend**

| Tecnologia    |   Versão    | Papel no projeto                                                       |
| ------------- | :---------: | ---------------------------------------------------------------------- |
| Python        |    3.14     | Linguagem escolhida para a entrega                                     |
| Flask         |    3.1.3    | Framework web que expõe a API REST de cada agência                     |
| PyJWT         |   2.13.0    | Geração e validação dos tokens JWT                                     |
| Requests      |   2.34.2    | Chamadas HTTP entre agências na rota interna do extrato consolidado    |
| pika          |    1.4.4    | Cliente do RabbitMQ para publicar e consumir mensagens entre agências  |
| Flask-Cors    |    6.0.5    | Autoriza o frontend, que roda em outra origem, a consumir a API        |
| python-dotenv |    1.2.3    | Carrega a chave secreta a partir do `.env`, fora do controle de versão |
| Werkzeug      | (via Flask) | Hash das senhas com pbkdf2                                             |

**Frontend**

| Tecnologia   | Versão | Papel no projeto                                               |
| ------------ | :----: | -------------------------------------------------------------- |
| Vue.js       |  3.5   | Framework da interface, com Composition API e `<script setup>` |
| TypeScript   |  6.0   | Tipagem estática em todo o código do frontend                  |
| Vite         |  8.3   | Servidor de desenvolvimento e empacotamento                    |
| Vue Router   |  5.3   | Rotas e guards de autenticação e de papel                      |
| Pinia        |  4.0   | Gerenciamento de estado no padrão Setup Store                  |
| Axios        |  1.20  | Cliente HTTP, com interceptors de token, erro e carregamento   |
| Zod          |  4.6   | Validação dos formulários com tipos inferidos do schema        |
| Tailwind CSS |  4.3   | Estilização, sobre um design system com tokens próprios        |

**Mobile**

| Tecnologia             | Versão | Papel no projeto                                                        |
| ---------------------- | :----: | ----------------------------------------------------------------------- |
| Flutter                |  3.47  | Framework do app, com widgets Cupertino para o visual do iOS            |
| Dart                   |  3.13  | Linguagem do app                                                        |
| http                   |  1.6   | Cliente HTTP oficial do Dart, usado em todas as chamadas às agências    |
| flutter_secure_storage |  11.2  | Guarda o token JWT no Keychain do iOS e no Keystore do Android          |
| sqflite                |  2.4   | SQLite local: cache de saldos e vetores e a fila de operações pendentes |
| shared_preferences     |  2.5   | Preferências simples: agência de destino fixada e tema escolhido        |
| path                   |  1.9   | Monta o caminho do arquivo do banco local                               |
| flutter_localizations  |  SDK   | Textos e formatos do sistema em português                               |

A escolha de **Python com Flask** atende à exigência do roteiro, que permite Java ou Python e proíbe a entrega em Node.js. O **Vue** foi escolhido no frontend, cuja tecnologia era livre. No app, o **Flutter** é obrigatório pelo roteiro, e a regra foi usar o mínimo de pacotes de terceiros: fora o `flutter_secure_storage` e o `sqflite`, todos são da própria equipe do Flutter e do Dart. Gerenciamento de estado, navegação, injeção de dependências e animações usam só o que o Flutter já oferece.

---

## 🏗 Arquitetura

### Backend: as três agências

O ponto central é que **existe um único código-fonte**, executado três vezes com identidades diferentes. A variável de ambiente `AGENCIA_ID` define quem é quem, e a partir dela cada processo descobre sua porta e sua fatia de contas. Não há nenhum código específico por agência.

```
Agência 0 (porta 4035)      Agência 1 (porta 4036)      Agência 2 (porta 4037)
contas 0, 3, 6, 9...        contas 1, 4, 7, 10...       contas 2, 5, 8, 11...
        │                            │                            │
        ├──────── RabbitMQ: exchange topic iceibank.eventos ──────┤
        │           (crédito remoto e confirmação de entrega)      │
        │                                                          │
        └──────────── HTTP + token de serviço ────────────────────┘
                         (extrato consolidado)
```

A organização interna segue MVC:

- **`routes.py`** declara as rotas e, junto de cada uma, a proteção que ela exige. A política de acesso do sistema inteiro pode ser lida em um arquivo só.
- **`controllers/`** recebem a requisição, validam a entrada, aplicam a regra de negócio e devolvem a resposta.
- **`services/`** concentram o que não é HTTP: o relógio vetorial, a mensageria com o RabbitMQ, o registro de eventos, a emissão e validação de tokens e o repositório de usuários.
- **`middlewares/`** guardam as três funções de proteção de rota, com nomes que dizem o que exigem: `requer_autenticacao`, `requer_admin` e `requer_servico`.

As contas ficam **em memória**, uma decisão do próprio roteiro: o foco da sprint é REST, particionamento e relógio lógico, não persistência. Isso significa que as contas somem quando uma agência é reiniciada. As credenciais, por outro lado, ficam em um arquivo compartilhado pelas três agências, porque um correntista cadastrado em uma delas precisa conseguir entrar e receber conta em qualquer outra.

### Frontend: o internet banking

O frontend segue arquitetura **baseada em funcionalidades com uma camada compartilhada**:

- **`app/`** concentra a inicialização e o roteador, com os guards que decidem o que cada rota exige.
- **`modules/`** isola cada funcionalidade (`landing`, `auth`, `home`, `accounts`, `transfers` e `brand`, a página de identidade visual), com suas páginas, componentes e serviços. Um módulo nunca importa de outro: o que é usado por mais de um vai para `shared/`. A exceção é `schemas`, que reúne os schemas Zod de validação dos formulários.
- **`shared/`** é a biblioteca interna: componentes reutilizáveis, composables, layout, a instância única do Axios e as stores globais.

Cada componente vive em uma pasta própria, no formato `NomeComponente/index.vue`, e declara o próprio nome com `defineOptions` para continuar identificável no Vue DevTools e nas mensagens de aviso.

Três decisões merecem destaque:

**O token é anexado em um lugar só.** Um interceptor de requisição injeta o cabeçalho `Authorization` antes de qualquer chamada sair. Nenhuma tela precisa saber que o token existe, e não há como esquecer de enviá-lo em uma rota nova.

**O armazenamento é feito no `sessionStorage`, não no `localStorage`.** Assim o token morre junto com a aba, reduzindo a janela de exposição. Junto dele é guardado o instante de expiração, validado a cada leitura, e um interceptor de resposta trata o HTTP 401 avisando a pessoa, limpando a sessão e devolvendo-a ao login.

**A agência é descoberta automaticamente.** Como a regra da partição é conhecida, o frontend calcula qual agência atende cada conta e direciona a requisição sozinho. O controle manual continua disponível para fixar uma agência e demonstrar o comportamento da partição.

**O SEO tem uma única fonte de verdade.** O arquivo `src/app/seo/pages.ts` define caminho, título, descrição e indexação de cada página. O roteador usa esses dados para atualizar as tags a cada navegação, e um plugin do Vite (`vite-plugins/seo.ts`) usa os mesmos dados no build para gerar o HTML de cada rota, o `robots.txt` e o `sitemap.xml`.

### Mobile: o app Flutter

O app segue a **arquitetura recomendada pela documentação oficial do Flutter**, em camadas e no padrão MVVM:

- **`data/services/`** fala com o mundo externo: o `ApiClient` (HTTP, token, failover entre agências), o armazenamento seguro da sessão e o banco SQLite.
- **`data/repositories/`** é a fonte da verdade de cada assunto: autenticação, contas, usuários, liderança, sincronização, agência de destino e tema. Eles nunca dependem uns dos outros.
- **`domain/models/`** guarda os modelos imutáveis, como conta, extrato, operação pendente e estado da liderança.
- **`ui/`** é dividida por funcionalidade (`auth`, `home`, `operations`, `transfers`, `management`, `leadership`, `sync`, `settings`), cada uma com seus view models (`ChangeNotifier`) e widgets. O design system fica em `ui/core`, com as mesmas cores, raios e tipografia do web, em versões clara e escura.

As decisões que mais pesaram:

**O app conversa com as agências do mesmo jeito que o web.** Mesmo contrato, mesmas rotas e a mesma regra `id % 3` para escolher a agência. A diferença é o endereço: no emulador Android, o Mac é `10.0.2.2`; no simulador do iOS, `127.0.0.1`. As configurações nativas liberam HTTP sem criptografia só para a rede local.

**O painel de liderança consulta as 3 agências em paralelo, a cada 3 segundos**, o mesmo intervalo do heartbeat do backend. A líder em destaque vem da primeira agência que responde, sempre na ordem 0 → 1 → 2, o que evita que o painel alterne entre agências que ainda discordam durante uma eleição. As consultas param quando o app vai para segundo plano.

**O modo offline-first usa o vetor como versão da conta.** O vetor vem de `GET /contas/<id>` e é guardado no SQLite junto do saldo. Operações feitas sem conexão entram numa fila, em ordem, cada uma com o vetor conhecido. A reconexão é detectada tentando a fila a cada 4 segundos enquanto houver pendências, e não pelo `connectivity_plus`: ele só informa se o aparelho tem rede, não se a agência responde, e com as agências em `localhost` desligar o Wi-Fi do computador nem chegaria ao simulador. Duas operações seguidas na mesma agência têm o vetor encadeado, já que cada sincronização avança exatamente uma posição, para que a segunda não vire um conflito falso.

**Nada é aplicado às cegas.** No `409`, o app troca o saldo provisório pelo real, marca a operação como "não aplicada" e pede uma decisão. Uma nova tentativa automática poderia sacar duas vezes, se a mudança tivesse sido a mesma operação feita por outro caminho. A justificativa completa está nas Partes E e F do [`RESPOSTAS.md`](RESPOSTAS.md).

### Sobre a pasta `agencia-express`

O roteiro traz o código de referência em **Node.js/Express** apenas como material didático, para que o aluno entenda a lógica com clareza, e proíbe explicitamente a entrega nessa linguagem.

A pasta [`agencia-express/`](agencia-express/) contém essa implementação de referência, que reproduzi primeiro para validar os conceitos antes de partir para a entrega. Ela acompanha o roteiro até o Sprint 3, com relógio vetorial, mensageria pelo RabbitMQ, eleição pelo algoritmo de Bully e o endpoint de sincronização offline-first, mas não inclui as funcionalidades adicionais, que são autorais. **Ela não faz parte da entrega**: serviu como laboratório de estudo e está mantida no repositório apenas como registro do processo.

A entrega avaliável é a pasta [`agencia/`](agencia/), escrita em Python com Flask, junto do frontend em [`frontend/`](frontend/) e do app em [`app_mobile/`](app_mobile/).

---

## ⚙️ Instalação e Execução

O ICEIBank roda em **até 5 terminais simultâneos**: um para cada uma das três agências, mais um para o frontend e outro para o app mobile, se quiser usar os dois clientes. Essa separação não é detalhe de execução, é a essência do projeto: cada agência é um processo independente, com sua própria memória e seu próprio relógio lógico.

| Terminal | O que roda      | Porta |
| :------: | --------------- | :---: |
|    1     | Agência 0       | 4035  |
|    2     | Agência 1       | 4036  |
|    3     | Agência 2       | 4037  |
|    4     | Frontend (Vite) | 5173  |
|    5     | App mobile      |   -   |

### Pré-requisitos

- **Python 3.10+** (o projeto foi desenvolvido com o 3.14)
- **Node.js 22.18+ ou 24.12+** e npm, para o frontend
- **Flutter 3.47+**, para o app mobile, com o **Xcode** (simulador do iOS, só no macOS) ou o **Android Studio** (emulador Android). O `flutter doctor` precisa passar sem erros na plataforma escolhida
- **Git**

### 📦 Passo 1: clonar e preparar o backend

```bash
git clone https://github.com/arturbomtempo-learning/iceibank.git
cd iceibank/agencia
```

Crie o ambiente virtual e instale as dependências:

```bash
# macOS e Linux
python3 -m venv .venv
./.venv/bin/pip install -r requirements.txt
```

```powershell
# Windows (PowerShell)
python -m venv .venv
.\.venv\Scripts\pip install -r requirements.txt
```

Em seguida, crie o arquivo de variáveis de ambiente:

```bash
# macOS e Linux
cp .env.example .env
```

```powershell
# Windows (PowerShell)
Copy-Item .env.example .env
```

O `.env` guarda a chave que assina os tokens JWT. Ela precisa ser a **mesma nas três agências**, porque é o que permite uma validar o token de serviço emitido pela outra. O valor do exemplo já funciona para uso local, mas para gerar uma chave forte:

```bash
python3 -c "import secrets; print(secrets.token_hex(32))"
```

Cole o resultado no campo `JWT_SECRET_KEY` do `.env`.

**Configurar o RabbitMQ no CloudAMQP.** O `.env` guarda também a `RABBITMQ_URL`, a URL AMQP da instância do RabbitMQ usada na mensageria entre as agências. Ela precisa ser a **mesma nas três agências**, e **sem ela a agência não inicia**: o processo para logo na subida com `RuntimeError: Defina a variável de ambiente RABBITMQ_URL...`.

O projeto usa o **CloudAMQP**, um RabbitMQ gerenciado na nuvem com plano gratuito. Para criar a sua instância:

1. Acesse <https://www.cloudamqp.com/> e crie uma conta gratuita (dá para entrar com Google ou GitHub).
2. Clique em **Create New Instance**.
3. Escolha o plano **Little Lemur - Free**, dê um nome à instância (por exemplo, `iceibank`) e selecione uma região próxima.
4. Abra os detalhes da instância criada e copie o campo **AMQP URL**, que tem este formato:

```text
amqps://usuario:senha@host.cloudamqp.com/vhost
```

Essa URL já inclui usuário, senha e vhost, e é tudo o que a aplicação precisa para se conectar. Agora escolha **uma** das duas formas de entregá-la às agências.

**Opção 1, no `.env` (recomendada).** Abra `agencia/.env` e preencha a linha da `RABBITMQ_URL` com a URL copiada:

```env
RABBITMQ_URL="amqps://usuario:senha@host.cloudamqp.com/vhost"
```

Como as três agências leem o mesmo `.env`, basta fazer isso uma vez. O arquivo não é versionado, então a senha da instância não vai para o repositório.

**Opção 2, no terminal.** Defina a variável na sessão antes de rodar a agência:

```bash
# macOS e Linux
export RABBITMQ_URL="amqps://usuario:senha@host.cloudamqp.com/vhost"
```

```powershell
# Windows (PowerShell)
$env:RABBITMQ_URL="amqps://usuario:senha@host.cloudamqp.com/vhost"
```

Nesse caso, a variável vale só para aquele terminal: ela precisa ser definida em **cada um dos três terminais** do Passo 2, e de novo sempre que você abrir um terminal novo. Se ela estiver definida no terminal e também no `.env`, o valor do terminal prevalece.

Para ver exchanges, filas e mensagens enquanto depura, use o botão **RabbitMQ Manager** no painel do CloudAMQP.

> Prefere rodar o RabbitMQ localmente? Com Docker, suba `docker run -d --name rabbitmq-iceibank -p 5672:5672 -p 15672:15672 rabbitmq:3-management` e use `RABBITMQ_URL="amqp://guest:guest@localhost:5672/"`. A aplicação funciona igual, só muda o valor da variável.

### 🏦 Passo 2: subir as três agências

Abra **três terminais** e rode um comando em cada um. Todos partem da pasta `agencia`. O que muda entre eles é apenas a variável `AGENCIA_ID`, que define a identidade daquele processo: o mesmo código-fonte, executado três vezes.

**Terminal 1, Agência 0:**

```bash
# macOS e Linux
cd iceibank/agencia
AGENCIA_ID=0 ./.venv/bin/python src/app.py
```

```powershell
# Windows (PowerShell)
cd iceibank\agencia
$env:AGENCIA_ID=0; .\.venv\Scripts\python src\app.py
```

**Terminal 2, Agência 1:**

```bash
# macOS e Linux
cd iceibank/agencia
AGENCIA_ID=1 ./.venv/bin/python src/app.py
```

```powershell
# Windows (PowerShell)
cd iceibank\agencia
$env:AGENCIA_ID=1; .\.venv\Scripts\python src\app.py
```

**Terminal 3, Agência 2:**

```bash
# macOS e Linux
cd iceibank/agencia
AGENCIA_ID=2 ./.venv/bin/python src/app.py
```

```powershell
# Windows (PowerShell)
cd iceibank\agencia
$env:AGENCIA_ID=2; .\.venv\Scripts\python src\app.py
```

Cada terminal deve imprimir a agência e a porta em que está ouvindo, por exemplo `[Agência 0] ouvindo na porta 4035`, e logo depois a confirmação de que o consumidor da fila está ativo, `[mensageria] consumindo fila-agencia-0 ...`. Deixe os três abertos: eles precisam ficar rodando ao mesmo tempo para que as transferências entre agências e o extrato consolidado funcionem.

> No Windows, o Firewall do Windows Defender pode pedir permissão de rede na primeira execução de cada agência. Clique em **Permitir acesso**.

### 💻 Passo 3: subir o frontend

Abra o **quarto terminal**, a partir da raiz do repositório:

```bash
cd iceibank/frontend
npm install
```

```bash
# macOS e Linux
cp .env.example .env
```

```powershell
# Windows (PowerShell)
Copy-Item .env.example .env
```

```bash
npm run dev
```

O terminal mostra o endereço da aplicação, normalmente `http://localhost:5173`. Abra no navegador.

> Se a porta 5173 estiver ocupada, o Vite escolhe outra automaticamente (5174, por exemplo) e avisa no terminal. O backend aceita qualquer porta local, então a aplicação continua funcionando; basta usar o endereço que ele imprimir.

O `.env` do frontend também tem a `SITE_URL`, o endereço público do site. Ela é usada só no build, para gerar o link canônico, a imagem de compartilhamento em redes sociais, o `robots.txt` e o `sitemap.xml`. Para rodar localmente, o valor do exemplo já serve; ao publicar o frontend, troque pelo domínio real (por exemplo, `https://iceibank.com.br`).

### 🛑 Como parar

Pressione **Ctrl+C** em cada terminal. Vale lembrar que as contas ficam **em memória**: ao parar as agências, todas as contas são perdidas e precisam ser recriadas na próxima execução. Os usuários cadastrados, por outro lado, ficam salvos em arquivo e sobrevivem ao reinício.

### 🔑 Passo 4: primeiro acesso

O sistema nasce com um único usuário, o gerente:

| Usuário | Senha       | Papel   |
| ------- | ----------- | ------- |
| `admin` | `admin1234` | Gerente |

Como as contas são recriadas a cada execução, o roteiro de uma sessão nova é:

1. Entrar como `admin`
2. Cadastrar um correntista em **Novo correntista** (escolhendo usuário e senha)
3. Abrir uma conta para ele em **Abrir conta**, informando número, titular e o usuário dono
4. Sair e entrar com o correntista para operar a conta

O número da conta define a agência: **0, 3, 6...** ficam na Agência 0; **1, 4, 7...** na Agência 1; **2, 5, 8...** na Agência 2. A própria tela avisa qual agência receberá o cadastro conforme você digita o número.

> Para ver o extrato consolidado em ação, abra contas do mesmo correntista em agências diferentes, por exemplo as contas 6, 7 e 8. A tela inicial passa a mostrar as três, com o saldo somado.

### 📱 Passo 5: rodar o app mobile

Com as três agências no ar, abra um emulador ou simulador:

- **iOS (macOS):** `open -a Simulator`
- **Android:** no Android Studio, **Device Manager**, crie um aparelho (por exemplo, Pixel 9) e clique em ▶

Depois, no quinto terminal:

```bash
cd iceibank/app_mobile
flutter pub get
flutter run
```

Se houver mais de um aparelho aberto, o Flutter pergunta em qual rodar. A primeira compilação para Android baixa o Gradle e as dependências e leva alguns minutos; as próximas levam segundos. Avisos `WARNING: A restricted method in java.lang.System` durante a compilação vêm do Gradle com Java recente e podem ser ignorados.

O app encontra as agências sozinho: `127.0.0.1` no simulador do iOS e `10.0.2.2` no emulador Android. O projeto foi validado nesses dois ambientes.

O primeiro acesso é igual ao do web: entre como `admin` / `admin1234`, cadastre um correntista e abra uma conta para ele, tudo pelas ações rápidas da home.

**Para testar o modo offline-first**, o app precisa perder o contato com a agência da conta:

- **No emulador Android**, ative o **modo avião** no painel rápido.
- **No simulador do iOS**, que não tem modo avião e acessa as agências por `localhost`, desligar o Wi-Fi não tem efeito. Pare a agência da conta com `Ctrl+C`; o roteiro fala justamente em "sem conexão com a agência responsável".

Os testes automatizados do app rodam com `flutter test`, e a análise estática com `flutter analyze`.

### 🕒 Linha do tempo unificada

Depois de gerar alguns eventos, é possível ver a linha do tempo das três agências juntas, com os pares concorrentes identificados pelo relógio vetorial:

```bash
# macOS e Linux
cd iceibank/agencia
./.venv/bin/python mesclar_logs.py
```

```powershell
# Windows (PowerShell)
cd iceibank\agencia
.\.venv\Scripts\python mesclar_logs.py
```

Para ver só a parte da eleição de líder, o script `historico_lideranca.py` filtra dos mesmos logs os eventos do algoritmo de Bully e termina com a linha do tempo de líderes, mostrando a partir de que momento cada agência assumiu a liderança:

```bash
# macOS e Linux
cd iceibank/agencia
./.venv/bin/python historico_lideranca.py
```

```powershell
# Windows (PowerShell)
cd iceibank\agencia
.\.venv\Scripts\python historico_lideranca.py
```

### 🧯 Problemas comuns

| Sintoma                                                       | Causa provável                                     | Solução                                                                              |
| ------------------------------------------------------------- | -------------------------------------------------- | ------------------------------------------------------------------------------------ |
| A agência não sobe e reclama de `JWT_SECRET_KEY`              | O arquivo `.env` não foi criado                    | Copie o `.env.example` para `.env` na pasta `agencia`                                |
| A agência não sobe e reclama de `RABBITMQ_URL`                | A variável não está no `.env` nem no terminal      | Preencha a `RABBITMQ_URL` no `agencia/.env` com a AMQP URL do CloudAMQP              |
| `Address already in use` ao subir uma agência                 | A porta já está ocupada por uma execução anterior  | Encerre o processo antigo ou reinicie o terminal                                     |
| Todas as telas mostram "não foi possível falar com a agência" | Alguma agência não está rodando                    | Confirme que os três terminais estão ativos                                          |
| As contas sumiram depois de reiniciar                         | Comportamento esperado: as contas ficam em memória | Recrie as contas entrando como `admin`                                               |
| "Já existe um usuário com esse nome" após reiniciar           | Os usuários são salvos em arquivo, e não somem     | Use outro nome, ou apague `agencia/data/usuarios.json` para voltar apenas ao `admin` |
| A sincronização offline sempre volta como conflito            | Algo mudou na agência depois da última leitura     | Puxe a home para atualizar antes de ficar offline; qualquer evento na agência conta  |
| A primeira compilação Android parece travada                  | O Gradle está baixando as dependências             | Aguarde alguns minutos; se passar de 15, rode `flutter run -v` para ver a etapa      |

---

## 🔌 Endpoints da API

Todas as rotas, exceto o login e as do algoritmo de Bully, exigem o cabeçalho `Authorization: Bearer <token>`. As rotas `/bully/*` seguem o roteiro do Sprint 3, que as define sem autenticação.

| Método | Rota                        | Proteção         | Descrição                                                 |
| :----: | --------------------------- | ---------------- | --------------------------------------------------------- |
| `POST` | `/auth/login`               | pública          | Autentica e devolve o token JWT                           |
| `POST` | `/usuarios`                 | gerente          | Cadastra um novo correntista                              |
| `POST` | `/contas`                   | gerente          | Abre uma conta na agência responsável pelo número         |
| `GET`  | `/contas/<id>`              | dono ou gerente  | Consulta o saldo de uma conta, com o vetor atual          |
| `POST` | `/contas/<id>/depositar`    | dono ou gerente  | Credita um valor                                          |
| `POST` | `/contas/<id>/sacar`        | dono ou gerente  | Debita um valor                                           |
| `POST` | `/contas/<id>/sincronizar`  | dono ou gerente  | Aplica uma operação feita offline, se o vetor não mudou   |
| `POST` | `/transferencias`           | dono ou gerente  | Transfere, resolvendo local ou entre agências             |
| `GET`  | `/extrato`                  | autenticado      | ⭐ Extrato consolidado das três agências                  |
| `GET`  | `/interno/contas/<usuario>` | token de serviço | Rota interna: contas de um usuário nesta agência          |
| `POST` | `/bully/eleicao`            | sem autenticação | Recebe uma mensagem de eleição de uma agência de id menor |
| `POST` | `/bully/coordenador`        | sem autenticação | Recebe o anúncio da nova líder                            |
| `GET`  | `/bully/lider`              | sem autenticação | Informa qual agência esta agência reconhece como líder    |

O crédito entre agências não passa por uma rota HTTP: ele trafega pelo RabbitMQ, na exchange `topic` `iceibank.eventos`, e cada agência consome a própria fila durável, `fila-agencia-<id>`.

| Routing key                | Publicada por      | Conteúdo                                                    |
| -------------------------- | ------------------ | ----------------------------------------------------------- |
| `agencia.<id>.creditar`    | agência de origem  | Crédito a aplicar na conta de destino, com o vetor de envio |
| `agencia.<id>.confirmacao` | agência de destino | ⭐ Desfecho do crédito, que dispara o estorno quando falha  |

---

## 📂 Estrutura de Pastas

```
iceibank/
├── agencia/                          # ✅ Entrega: backend em Python com Flask
│   ├── src/
│   │   ├── app.py                    # Cria a aplicação e sobe a agência
│   │   ├── config.py                 # Partição, portas, chave JWT e CORS
│   │   ├── routes.py                 # Rotas e a proteção exigida por cada uma
│   │   ├── controllers/              # Regras de negócio por recurso
│   │   │   ├── auth_controller.py
│   │   │   ├── bully_controller.py   # Rotas de eleição e consulta da líder
│   │   │   ├── contas_controller.py
│   │   │   ├── transferencias_controller.py
│   │   │   ├── usuarios_controller.py
│   │   │   └── extrato_controller.py # ⭐ Funcionalidade adicional
│   │   ├── services/
│   │   │   ├── relogio_vetorial.py   # As três regras do relógio vetorial
│   │   │   ├── comparar_vetores.py   # Relação causal entre dois vetores
│   │   │   ├── mensageria.py         # Publicação e consumo no RabbitMQ
│   │   │   ├── registro_eventos.py   # Log de eventos em JSON Lines
│   │   │   ├── bully_service.py      # Algoritmo de Bully: eleição, coordenador e heartbeat
│   │   │   ├── auth_service.py       # Emissão e validação dos tokens
│   │   │   └── repositorio_usuarios.py
│   │   └── middlewares/
│   │       └── auth_middleware.py    # requer_autenticacao, requer_admin, requer_servico
│   ├── data/                         # Logs de eventos e usuários (não versionados)
│   ├── .env.example                  # JWT_SECRET_KEY e RABBITMQ_URL
│   ├── mesclar_logs.py               # Linha do tempo causal das 3 agências
│   ├── historico_lideranca.py        # Histórico de eleições e de líderes das 3 agências
│   └── requirements.txt
│
├── frontend/                         # ✅ Entrega: interface web em Vue
│   ├── src/
│   │   ├── app/                      # Inicialização, rotas, guards e SEO
│   │   ├── modules/                  # landing, auth, home, accounts, transfers, brand, schemas
│   │   ├── shared/                   # Componentes, stores, serviços e layout
│   │   └── style.css                 # Design system com tokens de cor
│   ├── public/                       # Favicon, ícones, imagem de compartilhamento e manifesto
│   ├── vite-plugins/seo.ts           # Gera o HTML de cada rota, robots.txt e sitemap.xml
│   ├── .env.example                  # URLs das agências e SITE_URL
│   └── package.json
│
├── app_mobile/                       # ✅ Entrega: app em Flutter (Sprint 3)
│   ├── lib/
│   │   ├── config/                   # Endereços das agências e montagem das dependências
│   │   ├── data/
│   │   │   ├── services/             # ApiClient, sessão segura e banco SQLite
│   │   │   └── repositories/         # Contas, sessão, liderança, sincronização, tema...
│   │   ├── domain/models/            # Conta, extrato, operação pendente, liderança
│   │   ├── ui/                       # Telas por funcionalidade, cada uma com view models
│   │   └── utils/                    # Moeda, horários e formatadores
│   ├── test/                         # Testes de repositórios, modelos e view models
│   ├── android/ e ios/               # Projetos nativos, ícones e liberação da rede local
│   └── pubspec.yaml
│
├── agencia-express/                  # 📖 Referência em Node.js do roteiro (não entregue)
├── evidencias/
│   ├── sprint1/                      # Prints dos testes do Sprint 1
│   ├── sprint2/                      # Prints dos testes do Sprint 2
│   └── sprint3/                      # Prints dos testes do Sprint 3
├── enunciado/                        # Roteiros das sprints 1, 2 e 3
├── RESPOSTAS.md                      # Respostas conceituais e decisões de design
└── README.md
```

---

## 🖼️ Evidências

Todos os testes foram executados e registrados em [`evidencias/sprint1/`](evidencias/sprint1/), [`evidencias/sprint2/`](evidencias/sprint2/) e [`evidencias/sprint3/`](evidencias/sprint3/). Nos prints de terminal, a data aparece no próprio terminal ou na barra de menus do macOS. Os roteiros pedem o `Get-Date` do PowerShell, mas o projeto foi executado no macOS, onde a data vem do `date` e da barra de menus. Nos prints do app, aparece o relógio do aparelho, e quando o comportamento depende do backend, o terminal da agência fica ao lado, com o horário de cada requisição. As evidências marcadas com ➕ não foram pedidas pelo roteiro e complementam as obrigatórias.

### Sprint 1

**Backend e conceitos distribuídos**

Os prints do Sprint 1 registram o comportamento da época, com relógio de Lamport e chamada HTTP direta entre agências. O Sprint 2 substituiu os dois, como mostram as evidências da tabela seguinte.

| Evidência                                                                                 | O que demonstra                                               |
| ----------------------------------------------------------------------------------------- | ------------------------------------------------------------- |
| [`transferencia-local.png`](evidencias/sprint1/transferencia-local.png)                   | Transferência dentro da mesma agência                         |
| [`transferencia-entre-agencias.png`](evidencias/sprint1/transferencia-entre-agencias.png) | Transferência entre agências, com o crédito remoto            |
| [`falha-conhecida.png`](evidencias/sprint1/falha-conhecida.png)                           | Sprint 1: destino fora do ar, HTTP 502 e débito não revertido |
| [`linha-do-tempo.png`](evidencias/sprint1/linha-do-tempo.png)                             | Eventos das 3 agências ordenados por relógio de Lamport       |

**Autenticação (Parte F)**

| Evidência                                                               | O que demonstra                            |
| ----------------------------------------------------------------------- | ------------------------------------------ |
| [`auth-sem-token.png`](evidencias/sprint1/auth-sem-token.png)           | Requisição sem token recusada com HTTP 401 |
| [`auth-com-token.png`](evidencias/sprint1/auth-com-token.png)           | Operação concluída com token válido        |
| [`auth-token-expirado.png`](evidencias/sprint1/auth-token-expirado.png) | Token expirado recusado com HTTP 401       |

**Frontend (Parte G)**

| Evidência                                                                                 | O que demonstra                                          |
| ----------------------------------------------------------------------------------------- | -------------------------------------------------------- |
| [`frontend-login.png`](evidencias/sprint1/frontend-login.png)                             | Tela de login                                            |
| [`frontend-login-invalido.png`](evidencias/sprint1/frontend-login-invalido.png)           | Credenciais inválidas tratadas na interface              |
| [`frontend-cadastro.png`](evidencias/sprint1/frontend-cadastro.png)                       | Gerente cadastrando um correntista                       |
| [`frontend-abrir-conta.png`](evidencias/sprint1/frontend-abrir-conta.png)                 | Abertura de conta, com a agência responsável indicada    |
| [`frontend-saldo.png`](evidencias/sprint1/frontend-saldo.png)                             | Consulta de saldo na tela inicial                        |
| [`frontend-deposito.png`](evidencias/sprint1/frontend-deposito.png)                       | Depósito via formulário                                  |
| [`frontend-saque.png`](evidencias/sprint1/frontend-saque.png)                             | Saque via formulário                                     |
| [`frontend-transferencia-local.png`](evidencias/sprint1/frontend-transferencia-local.png) | Transferência na mesma agência pela interface            |
| [`frontend-transferencia.png`](evidencias/sprint1/frontend-transferencia.png)             | Transferência entre agências pela interface              |
| [`frontend-erro.png`](evidencias/sprint1/frontend-erro.png)                               | Saldo insuficiente exibido para a pessoa usuária         |
| [`frontend-erro-entre-agencias.png`](evidencias/sprint1/frontend-erro-entre-agencias.png) | Falha de transferência entre agências na interface       |
| [`frontend-sessao-expirada.png`](evidencias/sprint1/frontend-sessao-expirada.png)         | Token expirado encerrando a sessão e devolvendo ao login |

**Funcionalidade adicional do Sprint 1**

| Evidência                                                                         | O que demonstra                                                                                            |
| --------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| [`funcionalidade-adicional.png`](evidencias/sprint1/funcionalidade-adicional.png) | Cada agência conhece só a sua partição, e uma única chamada ao `/extrato` reúne as três com o saldo somado |

### Sprint 2

**Mensageria e relógio vetorial**

| Evidência                                                                         | O que demonstra                                                               |
| --------------------------------------------------------------------------------- | ----------------------------------------------------------------------------- |
| [`transferencia-assincrona.png`](evidencias/sprint2/transferencia-assincrona.png) | Transferência entre agências concluída pela fila do RabbitMQ                  |
| [`resiliencia-fila.png`](evidencias/sprint2/resiliencia-fila.png)                 | Destino fora do ar: mensagem retida na fila e entregue quando a agência volta |
| [`linha-do-tempo-causal.png`](evidencias/sprint2/linha-do-tempo-causal.png)       | Pares de eventos concorrentes identificados pelo relógio vetorial             |
| [`funcionalidade-adicional.png`](evidencias/sprint2/funcionalidade-adicional.png) | Confirmação de entrega: crédito confirmado e, na falha, estorno automático    |

### Sprint 3

**Partes A, B e C: eleição de líder pelo algoritmo de Bully**

| Evidência                                                               | O que demonstra                                                                             |
| ----------------------------------------------------------------------- | ------------------------------------------------------------------------------------------- |
| [`eleicao-inicial.png`](evidencias/sprint3/eleicao-inicial.png)         | As 3 agências sobem e convergem para a mesma líder, a Agência 2                             |
| [`failover.png`](evidencias/sprint3/failover.png)                       | A líder é derrubada, o heartbeat detecta a queda e as 2 restantes elegem a Agência 1        |
| [`failover-retorno.png`](evidencias/sprint3/failover-retorno.png)       | ➕ A Agência 2 volta ao ar e retoma a liderança                                             |
| [`historico-lideranca.png`](evidencias/sprint3/historico-lideranca.png) | Saída do `historico_lideranca.py`: líder inicial, queda e nova líder reconstruídas dos logs |

O roteiro pede print apenas da queda da líder, mas o passo 6 da tarefa da Parte B também manda subir de novo a agência derrubada e observar o que acontece. Esse retorno ganhou um print próprio porque mostra o outro lado do failover, que o primeiro print não cobre: a recuperação também é automática. Ao voltar, a Agência 2 inicia a própria eleição, não encontra ninguém de id maior, se declara líder e anuncia o resultado. As agências 0 e 1 aceitam o anúncio e passam a reconhecê-la, mesmo com a Agência 1 liderando normalmente até ali. É exatamente o comportamento de "valentão" que dá nome ao algoritmo, e o mesmo print mostra o seu custo: uma troca de liderança que ninguém pediu, tema da Pergunta 2 da Parte B. Os vetores também deixam uma marca da reinicialização. A Agência 2 volta com o relógio zerado, em `[0, 0, 1]`, porque o vetor fica em memória, e só volta a incorporar o que as outras agências já sabiam quando recebe delas uma mensagem que carrega vetor, como uma eleição ou um crédito remoto. As respostas ao anúncio de coordenador e as consultas do heartbeat não levam vetor.

**Parte D: app Flutter com painel de liderança**

| Evidência                                                                 | O que demonstra                                                                                      |
| ------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------- |
| [`app-lider-atual.png`](evidencias/sprint3/app-lider-atual.png)           | Com as 3 agências no ar, o painel mostra a Agência 2 como líder                                      |
| [`app-failover.png`](evidencias/sprint3/app-failover.png)                 | Antes e depois: a líder cai e o painel passa sozinho para a Agência 1, às 00:01:26, sem nenhum toque |
| [`app-failover-retorno.png`](evidencias/sprint3/app-failover-retorno.png) | ➕ A Agência 2 volta, e o painel registra sozinho a troca da Agência 1 para a 2                      |
| [`app-sem-agencias.png`](evidencias/sprint3/app-sem-agencias.png)         | ➕ As 3 agências fora do ar: o painel mostra "sem sinal", a última líder conhecida e segue tentando  |

O `app-failover.png` reúne as duas capturas, antes e depois, numa imagem só, como o roteiro permite. A troca de 2 para 1 aconteceu às 00:01:24 nos logs das agências e apareceu no app às 00:01:26, dentro do ciclo de 3 segundos de consulta.

**Parte E: sincronização offline-first no backend**

| Evidência                                                                     | O que demonstra                                                                                     |
| ----------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| [`conflito-sincronizacao.png`](evidencias/sprint3/conflito-sincronizacao.png) | Sincronização com o vetor antigo recusada com `409`, devolvendo o vetor atual e o estado da conta   |
| [`sincronizacao-aplicada.png`](evidencias/sprint3/sincronizacao-aplicada.png) | ➕ Passo 5 da tarefa: a mesma operação, com o `vetorAtual` devolvido no `409`, aplicada com sucesso |
| [`conflito-outra-conta.png`](evidencias/sprint3/conflito-outra-conta.png)     | ➕ `409` causado por uma operação em outra conta da mesma agência                                   |

O roteiro pede print só do conflito, mas o passo 5 da tarefa manda sincronizar de novo com o vetor atualizado, e esse sucesso ganhou um print próprio. O `conflito-outra-conta.png` documenta a simplificação discutida na Pergunta 2 da Parte E: a conta 300 continuava com o mesmo saldo, mas a criação da conta 303 avançou o vetor da agência, e a sincronização foi recusada mesmo assim.

**Parte F: app Flutter no modo offline-first**

| Evidência                                                           | O que demonstra                                                                                                 |
| ------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| [`app-offline.png`](evidencias/sprint3/app-offline.png)             | Em modo avião, o depósito fica guardado como pendente, sem erro, e o saldo aparece como provisório              |
| [`app-sincronizacao.png`](evidencias/sprint3/app-sincronizacao.png) | Antes e depois: ao reconectar, o app envia a operação sozinho, e o terminal da agência registra a sincronização |
| [`app-conflito.png`](evidencias/sprint3/app-conflito.png)           | Tarefa 5: o `409` tratado de forma visível, com o saldo real, a operação "não aplicada" e o pedido de decisão   |

A Parte F foi evidenciada no **emulador Android**, porque o roteiro pede o modo avião, que o simulador do iOS não tem. O `app-sincronizacao.png` também reúne antes e depois numa imagem só. O roteiro não dá nome ao print do conflito, então ele foi salvo como `app-conflito.png`. Para provocar o conflito, um depósito de R$ 20 ficou guardado no app em modo avião enquanto um depósito de R$ 30 era feito na mesma conta por `curl`. Ao reconectar, a agência recusou a sincronização com `409`, e o app trocou o saldo provisório de R$ 170 pelo real, de R$ 180, sem aplicar nada sozinho.

**⭐ Funcionalidade adicional do Sprint 3**

| Evidência                                                                         | O que demonstra                                                                                                     |
| --------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------- |
| [`funcionalidade-adicional.png`](evidencias/sprint3/funcionalidade-adicional.png) | Indicador de agências ativas: cada agência com o tempo de resposta e a líder que reconhece, antes e depois da queda |

As duas metades foram extraídas da gravação da tela. Às 00:31:07, as 3 agências respondiam em 3 ms e todas reconheciam a Agência 2. Às 00:31:13, a Agência 2 aparecia fora do ar e as outras duas já reconheciam a Agência 1. O indicador também sabe mostrar uma líder que parou de responder antes de ser substituída, mas esse estado não chegou a aparecer na gravação: a agência derrubada recusou a conexão na hora, e a nova líder foi eleita dentro de um único ciclo de consulta do app. Ele aparece quando a detecção demora mais, por exemplo com uma líder travada em vez de desligada, e está coberto pelos testes automatizados do app.

---

## 📖 Referências

- LAMPORT, Leslie. _Time, Clocks, and the Ordering of Events in a Distributed System._ Communications of the ACM, v. 21, n. 7, 1978.
- FIDGE, Colin J. _Timestamps in Message-Passing Systems That Preserve the Partial Ordering._ Proceedings of the 11th Australian Computer Science Conference, 1988.
- MATTERN, Friedemann. _Virtual Time and Global States of Distributed Systems._ Parallel and Distributed Algorithms, North-Holland, 1989.
- GARCIA-MOLINA, Hector. _Elections in a Distributed Computing System._ IEEE Transactions on Computers, v. C-31, n. 1, p. 48-59, 1982.
- GARCIA-MOLINA, Hector; SALEM, Kenneth. _Sagas._ Proceedings of the ACM SIGMOD International Conference on Management of Data, 1987.
- COULOURIS, George et al. _Distributed Systems: Concepts and Design._ 5th ed. Addison-Wesley, 2011.
- TANENBAUM, A. S.; VAN STEEN, M. _Sistemas Distribuídos: Princípios e Paradigmas._ Tradução da 2ª edição. Pearson, 2007.
- MARTIN, Robert C. _Arquitetura Limpa: o guia do artesão para estrutura e design de software._ Alta Books, 2019.
- JONES, M.; BRADLEY, J.; SAKIMURA, N. _RFC 7519 - JSON Web Token (JWT)._ IETF, 2015. Disponível em: <https://datatracker.ietf.org/doc/html/rfc7519>
- Flask. Documentação oficial. Disponível em: <https://flask.palletsprojects.com/>
- Vue.js. Documentação oficial. Disponível em: <https://vuejs.org/>
- PyJWT. Documentação oficial. Disponível em: <https://pyjwt.readthedocs.io/>
- RabbitMQ. Documentação oficial. Disponível em: <https://www.rabbitmq.com/docs>
- Flutter. Documentação oficial e guia de arquitetura de apps. Disponível em: <https://docs.flutter.dev/app-architecture>
- SQLite. Documentação oficial. Disponível em: <https://www.sqlite.org/docs.html>

---

## 🤖 Uso Responsável de IA

Seguindo a nota de transparência do próprio [`sprint-01.md`](enunciado/sprint-01.md), registro aqui, de forma aberta, como usei ferramentas de inteligência artificial neste trabalho. As ferramentas foram o **Claude Code** (com os modelos **Claude Sonnet 5** e, no Sprint 3, **Claude Opus 5.5**) e o **ChatGPT**, no modelo gratuito atualmente disponível (**GPT-5.6 Luna**).

**Onde a IA foi usada.** Diferente de um uso apenas cosmético, ela participou do desenvolvimento em quatro frentes: na implementação da **API em Flask**, na construção do **frontend em Vue** e do **app em Flutter**, e na redação deste `README.md` e do [`RESPOSTAS.md`](RESPOSTAS.md). No Sprint 3, ela também montou algumas evidências a partir das minhas próprias capturas: juntou pares de prints de antes e depois numa imagem só e extraiu quadros de uma gravação de tela feita por mim, sem alterar o conteúdo de nenhuma captura. Prefiro declarar isso com clareza a minimizar o papel que a ferramenta teve.

**Como foi usada.** O que separa um uso responsável de uma cópia irrefletida é o método, e aqui ele foi deliberado:

- **Engenharia de prompt.** Cada solicitação partiu de um contexto construído por mim: o enunciado da sprint, o padrão de arquitetura que eu queria seguir, as restrições do projeto e o comportamento esperado. Não descrevi problemas de forma vaga esperando uma solução pronta.
- **Direção das decisões de projeto.** As escolhas estruturais foram minhas, e várias contrariaram a primeira sugestão da ferramenta. Defini o modelo de credenciais e de papéis, o formato do armazenamento do token, a decisão de não repassar o token de sessão entre agências, o desenho da funcionalidade adicional, a identidade visual do frontend, o uso do SQLite no modo offline e a política de usar o mínimo de pacotes de terceiros no app. Em mais de um momento reverti alterações que extrapolavam o escopo do roteiro, para manter a fidelidade ao que foi pedido.
- **Revisão crítica linha a linha.** Nada entrou no repositório sem leitura e entendimento. Quando o comportamento não fez sentido, questionei e corrigi: bugs de interface, mensagens de erro imprecisas e inconsistências entre o que a tela mostrava e o que a API devolvia foram identificados por mim durante os testes.
- **Validação por evidência.** Todo o comportamento documentado foi executado e comprovado por mim, e está registrado nos prints das pastas [`evidencias/sprint1/`](evidencias/sprint1/), [`evidencias/sprint2/`](evidencias/sprint2/) e [`evidencias/sprint3/`](evidencias/sprint3/).

**O que continua sendo meu.** A compreensão do problema, as decisões de arquitetura, a validação de cada funcionalidade, a análise dos resultados observados nos logs e o conteúdo conceitual das respostas do [`RESPOSTAS.md`](RESPOSTAS.md), embasado nas referências bibliográficas listadas acima e no próprio roteiro.

Assumo integralmente a autoria e a responsabilidade por este trabalho e **estou apto a explicar e defender qualquer trecho entregue neste repositório**, seja o algoritmo do relógio vetorial, o fluxo de autenticação e autorização, a mensageria entre as agências, a eleição pelo algoritmo de Bully, o modo offline-first do app ou qualquer decisão tomada no frontend e no app.

---

## 🙏 Agradecimentos

- **Engenharia de Software PUC Minas**, pela estrutura acadêmica e pelo incentivo a boas práticas de engenharia desde os primeiros períodos.
- **Prof. Cristiano de Macêdo Neto**, por lecionar as aulas de Laboratório de Desenvolvimento de Aplicações Móveis e Distribuídas e por propor um roteiro que conecta teoria de Sistemas Distribuídos a um projeto real, evoluído ao longo de todo o semestre.

---

## 👤 Autor

| Nome                 | Foto                                                                                                                  | GitHub                                                                                                                                                                                            | LinkedIn                                                                                                                                                                                                   | Gmail                                                                                                                                                                                    |
| -------------------- | --------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Artur Bomtempo Colen | <div align="center"><img src="https://avatars.githubusercontent.com/u/96635074?v=4" width="70px" height="70px"></div> | <div align="center"><a href="https://github.com/arturbomtempo-dev"><img src="https://arturbomtempo-dev.github.io/arturbomtempo-cdn/assets/icons/github.png" width="35px" height="35px"></a></div> | <div align="center"><a href="https://www.linkedin.com/in/artur-bomtempo/"><img src="https://arturbomtempo-dev.github.io/arturbomtempo-cdn/assets/icons/linkedin.png" width="35px" height="35px"></a></div> | <div align="center"><a href="mailto:arturbcolen@gmail.com"><img src="https://arturbomtempo-dev.github.io/arturbomtempo-cdn/assets/icons/gmail.png" width="35px" height="35px"></a></div> |

---

## 📄 Licença

Este projeto é distribuído sob a [Licença MIT](./LICENSE.md).
