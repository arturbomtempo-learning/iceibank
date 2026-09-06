# ICEIBank

Um banco distribuído em três agências independentes, onde cada agência é um serviço REST autônomo, dono de uma partição das contas, que conversa com as demais pela rede para concluir transferências e ordena os eventos do sistema com o relógio lógico de Lamport.

![License](https://img.shields.io/badge/License-MIT-red?style=for-the-badge&logoColor=white)
![Python](https://img.shields.io/badge/Python-3.14-3776AB?style=for-the-badge&logo=python&logoColor=white)
![Flask](https://img.shields.io/badge/Flask-3.1-000000?style=for-the-badge&logo=flask&logoColor=white)
![Vue](https://img.shields.io/badge/Vue.js-3.5-4FC08D?style=for-the-badge&logo=vuedotjs&logoColor=white)
![TypeScript](https://img.shields.io/badge/TypeScript-6.0-3178C6?style=for-the-badge&logo=typescript&logoColor=white)
![Tailwind](https://img.shields.io/badge/Tailwind_CSS-4.3-06B6D4?style=for-the-badge&logo=tailwindcss&logoColor=white)
![JWT](https://img.shields.io/badge/Auth-JWT-D63AFF?style=for-the-badge&logo=jsonwebtokens&logoColor=white)
![Conceito](https://img.shields.io/badge/Sistemas_Distribuídos-Relógio_de_Lamport-555555?style=for-the-badge)
![Status](https://img.shields.io/badge/Sprint_1-Finalizada-brightgreen?style=for-the-badge)
![Repo Size](https://img.shields.io/github/repo-size/arturbomtempo-learning/iceibank?style=for-the-badge)
![Last Commit](https://img.shields.io/github/last-commit/arturbomtempo-learning/iceibank?style=for-the-badge)

---

## 🚧 Status do Projeto

Sprint 1 concluída. As três agências rodam simultaneamente com partição de contas, relógio de Lamport, transferências locais e entre agências, autenticação e autorização via JWT, frontend web completo e a funcionalidade adicional de extrato consolidado. Todas as evidências de teste e as respostas conceituais estão registradas no repositório.

Este é o primeiro de quatro sprints de um projeto que evolui ao longo do semestre: cada sprint parte do código do anterior e adiciona um novo conceito de Sistemas Distribuídos.

---

## 📚 Índice

- [ICEIBank](#iceibank)
    - [🚧 Status do Projeto](#-status-do-projeto)
    - [📚 Índice](#-índice)
    - [📝 Sobre o Projeto](#-sobre-o-projeto)
    - [🎬 Vídeo de Apresentação](#-vídeo-de-apresentação)
    - [✨ Funcionalidades Principais](#-funcionalidades-principais)
    - [⭐ Funcionalidade Adicional: Extrato Consolidado](#-funcionalidade-adicional-extrato-consolidado)
    - [🛠 Tecnologias Utilizadas](#-tecnologias-utilizadas)
    - [🏗 Arquitetura](#-arquitetura)
        - [Backend: as três agências](#backend-as-três-agências)
        - [Frontend: o internet banking](#frontend-o-internet-banking)
        - [Sobre a pasta `agencia-express`](#sobre-a-pasta-agencia-express)
    - [⚙️ Instalação e Execução](#️-instalação-e-execução)
        - [Pré-requisitos](#pré-requisitos)
        - [📦 Passo 1: clonar e preparar o backend](#-passo-1-clonar-e-preparar-o-backend)
        - [🏦 Passo 2: subir as três agências](#-passo-2-subir-as-três-agências)
        - [💻 Passo 3: subir o frontend](#-passo-3-subir-o-frontend)
        - [🛑 Como parar](#-como-parar)
        - [🔑 Passo 4: primeiro acesso](#-passo-4-primeiro-acesso)
        - [🕒 Linha do tempo unificada](#-linha-do-tempo-unificada)
        - [🧯 Problemas comuns](#-problemas-comuns)
    - [🔌 Endpoints da API](#-endpoints-da-api)
    - [📂 Estrutura de Pastas](#-estrutura-de-pastas)
    - [🖼️ Evidências](#️-evidências)
    - [📖 Referências](#-referências)
    - [🤖 Uso Responsável de IA](#-uso-responsável-de-ia)
    - [🙏 Agradecimentos](#-agradecimentos)
    - [👤 Autor](#-autor)
    - [📄 Licença](#-licença)

---

## 📝 Sobre o Projeto

O **ICEIBank** é um banco simplificado dividido em agências, desenvolvido como projeto da disciplina de Laboratório de Desenvolvimento de Aplicações Móveis e Distribuídas. A ideia central não é o domínio bancário em si, mas usá-lo como cenário para aplicar conceitos de Sistemas Distribuídos em um sistema que realmente funciona.

O ponto de partida é uma decisão de arquitetura: as contas são **particionadas**, não replicadas. Cada conta pertence a exatamente uma agência, determinada pela regra `número_da_conta % 3`. A conta 0 vive na Agência 0, a conta 1 na Agência 1, a conta 2 na Agência 2, a conta 3 volta para a Agência 0, e assim por diante. Nenhuma agência conhece as contas das outras.

Essa escolha é o que dá sentido a tudo o mais. Uma transferência entre contas da mesma agência é resolvida internamente, na memória do processo. Já uma transferência entre agências exige que a agência de origem debite localmente e faça uma chamada HTTP para a agência de destino creditar. Duas máquinas diferentes, dois relógios diferentes, uma operação só.

É aí que entra o conceito central da sprint: o **relógio lógico de Lamport**. Como não existe um relógio global confiável em um sistema distribuído, cada agência mantém um contador próprio e segue três regras para que a ordem causal dos eventos seja preservada mesmo entre processos independentes. Todo evento do sistema é registrado em log com seu timestamp lógico, e um script mescla os logs das três agências em uma linha do tempo única.

O projeto também expõe, de forma deliberada, uma limitação real: se a agência de destino cair no meio de uma transferência, o débito já aplicado **não é revertido** e o dinheiro desaparece temporariamente. Essa inconsistência não é escondida, ela é registrada no log e documentada, porque resolvê-la de verdade é o tema do Sprint 4, com transações distribuídas.

| Sprint | Conceito de Sistemas Distribuídos  |   Situação   |
| :----: | ---------------------------------- | :----------: |
| **1**  | **Relógio lógico de Lamport**      | ✅ Concluído |
|   2    | Relógio vetorial                   |  Planejado   |
|   3    | Consenso (eleição de líder)        |  Planejado   |
|   4    | Transações distribuídas (2PC/Saga) |  Planejado   |

---

## 🎬 Vídeo de Apresentação

Como parte da entrega, foi gravado um vídeo apresentando o projeto em funcionamento:

**▶️ [Assistir à apresentação do Sprint 1](https://youtu.be/fpBiZ1JiXc8)**

---

## ✨ Funcionalidades Principais

**Partição de contas entre agências.** Cada conta pertence a uma única agência, calculada por `id % 3`. Uma agência recusa explicitamente operar contas que não são suas, respondendo com erro em vez de fingir que a conta não existe.

**Relógio lógico de Lamport.** Implementa as três regras do algoritmo: incremento antes de cada evento local, incremento e envio do timestamp junto da mensagem, e ajuste para `max(contador_local, timestamp_recebido) + 1` ao receber. O contador é protegido por lock, já que o servidor atende requisições em múltiplas threads.

**Registro de eventos auditável.** Toda operação gera uma linha em `data/eventos-agencia-N.jsonl` com o tipo do evento, o timestamp de Lamport, a hora de parede e os detalhes. Sete tipos de evento são registrados, de `CRIAR_CONTA` a `TRANSFERENCIA_FALHOU`.

**Linha do tempo unificada.** O script `mesclar_logs.py` lê os logs das três agências e monta uma ordenação única por timestamp lógico, permitindo observar concorrência real e identificar eventos causalmente independentes.

**API REST em arquitetura MVC.** Rotas, controllers e services separados, com CRUD de contas, depósito, saque e transferências.

**Transferências locais e entre agências.** O frontend não precisa saber a diferença: envia origem, destino e valor, e o backend decide se resolve internamente ou se precisa chamar outra agência. A resposta informa qual dos dois casos ocorreu.

**Falha conhecida documentada.** Quando a agência de destino está indisponível, o débito já aplicado não é revertido. O sistema registra a inconsistência no log e responde com HTTP 502, deixando o problema visível em vez de mascarado.

**Autenticação com JWT.** Login com usuário e senha (guardada em hash), token assinado com expiração de uma hora, e todas as rotas de conta protegidas. Token ausente, inválido ou expirado é recusado com HTTP 401.

**Autorização em três camadas.** Além de autenticar, o sistema verifica permissões: papel de gerente para abrir contas e cadastrar correntistas, posse do recurso para movimentar uma conta específica, e um tipo de token separado para as chamadas internas entre agências. Falhas de permissão respondem com HTTP 403, distinguindo "não sei quem você é" de "sei quem você é, mas você não pode".

**Token de serviço para comunicação interna.** As chamadas entre agências não reutilizam o token de sessão da pessoa. A agência de origem gera um token próprio, de curtíssima duração e sem identidade de usuário, seguindo o princípio de menor privilégio.

**Frontend web completo.** Internet banking em Vue com login, visão consolidada de saldos, depósito, saque, transferências, cadastro de correntistas e abertura de contas, com tratamento visível de todos os erros retornados pela API.

**Roteamento automático de agência.** O frontend descobre sozinho qual agência atende cada conta e envia a requisição para o endereço certo, sem que a pessoa precise escolher. Um controle manual permite fixar uma agência específica para demonstrar o comportamento da partição.

---

## ⭐ Funcionalidade Adicional: Extrato Consolidado

Além do escopo obrigatório, a seção 2.1 do roteiro exige pelo menos uma funcionalidade autoral. A escolhida foi o **extrato consolidado**: um endpoint `GET /extrato` que reúne todas as contas do usuário logado nas três agências e devolve o saldo somado em uma única chamada.

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

---

## 🛠 Tecnologias Utilizadas

**Backend**

| Tecnologia    |   Versão    | Papel no projeto                                                       |
| ------------- | :---------: | ---------------------------------------------------------------------- |
| Python        |    3.14     | Linguagem escolhida para a entrega                                     |
| Flask         |    3.1.3    | Framework web que expõe a API REST de cada agência                     |
| PyJWT         |   2.13.0    | Geração e validação dos tokens JWT                                     |
| Requests      |   2.34.2    | Chamadas HTTP de uma agência para outra                                |
| Flask-Cors    |    6.0.5    | Autoriza o frontend, que roda em outra origem, a consumir a API        |
| python-dotenv |    1.2.3    | Carrega a chave secreta a partir do `.env`, fora do controle de versão |
| Werkzeug      | (via Flask) | Hash das senhas com pbkdf2                                             |

**Frontend**

| Tecnologia   | Versão | Papel no projeto                                               |
| ------------ | :----: | -------------------------------------------------------------- |
| Vue.js       |  3.5   | Framework da interface, com Composition API e `<script setup>` |
| TypeScript   |  6.0   | Tipagem estática em todo o código do frontend                  |
| Vite         |  8.1   | Servidor de desenvolvimento e empacotamento                    |
| Vue Router   |  5.3   | Rotas e guards de autenticação e de papel                      |
| Pinia        |  4.0   | Gerenciamento de estado no padrão Setup Store                  |
| Axios        |  1.20  | Cliente HTTP, com interceptors de token, erro e carregamento   |
| Zod          |  4.5   | Validação dos formulários com tipos inferidos do schema        |
| Tailwind CSS |  4.3   | Estilização, sobre um design system com tokens próprios        |

A escolha de **Python com Flask** atende à exigência do roteiro, que permite Java ou Python e proíbe a entrega em Node.js. O **Vue** foi escolhido no frontend, cuja tecnologia era livre.

---

## 🏗 Arquitetura

### Backend: as três agências

O ponto central é que **existe um único código-fonte**, executado três vezes com identidades diferentes. A variável de ambiente `AGENCIA_ID` define quem é quem, e a partir dela cada processo descobre sua porta e sua fatia de contas. Não há nenhum código específico por agência.

```
Agência 0 (porta 4035)      Agência 1 (porta 4036)      Agência 2 (porta 4037)
contas 0, 3, 6, 9...        contas 1, 4, 7, 10...       contas 2, 5, 8, 11...
        │                            │                            │
        └──────────── HTTP + token de serviço ────────────────────┘
                    (crédito remoto e extrato consolidado)
```

A organização interna segue MVC:

- **`routes.py`** declara as rotas e, junto de cada uma, a proteção que ela exige. A política de acesso do sistema inteiro pode ser lida em um arquivo só.
- **`controllers/`** recebem a requisição, validam a entrada, aplicam a regra de negócio e devolvem a resposta.
- **`services/`** concentram o que não é HTTP: o relógio de Lamport, o registro de eventos, a emissão e validação de tokens e o repositório de usuários.
- **`middlewares/`** guardam as três funções de proteção de rota, com nomes que dizem o que exigem: `requer_autenticacao`, `requer_admin` e `requer_servico`.

As contas ficam **em memória**, uma decisão do próprio roteiro: o foco da sprint é REST, particionamento e relógio lógico, não persistência. Isso significa que as contas somem quando uma agência é reiniciada. As credenciais, por outro lado, ficam em um arquivo compartilhado pelas três agências, porque um correntista cadastrado em uma delas precisa conseguir entrar e receber conta em qualquer outra.

### Frontend: o internet banking

O frontend segue arquitetura **baseada em funcionalidades com uma camada compartilhada**:

- **`app/`** concentra a inicialização e o roteador, com os guards que decidem o que cada rota exige.
- **`modules/`** isola cada funcionalidade (`auth`, `accounts`, `transfers`, `home`), com suas páginas e serviços. Um módulo nunca importa de outro.
- **`shared/`** é a biblioteca interna: componentes reutilizáveis, composables, layout, a instância única do Axios e as stores globais.

Três decisões merecem destaque:

**O token é anexado em um lugar só.** Um interceptor de requisição injeta o cabeçalho `Authorization` antes de qualquer chamada sair. Nenhuma tela precisa saber que o token existe, e não há como esquecer de enviá-lo em uma rota nova.

**O armazenamento é feito no `sessionStorage`, não no `localStorage`.** Assim o token morre junto com a aba, reduzindo a janela de exposição. Junto dele é guardado o instante de expiração, validado a cada leitura, e um interceptor de resposta trata o HTTP 401 avisando a pessoa, limpando a sessão e devolvendo-a ao login.

**A agência é descoberta automaticamente.** Como a regra da partição é conhecida, o frontend calcula qual agência atende cada conta e direciona a requisição sozinho. O controle manual continua disponível para fixar uma agência e demonstrar o comportamento da partição.

### Sobre a pasta `agencia-express`

O roteiro traz o código de referência em **Node.js/Express** apenas como material didático, para que o aluno entenda a lógica com clareza, e proíbe explicitamente a entrega nessa linguagem.

A pasta [`agencia-express/`](agencia-express/) contém essa implementação de referência, que reproduzi primeiro para validar os conceitos antes de partir para a entrega. **Ela não faz parte da entrega**: serviu como laboratório de estudo e está mantida no repositório apenas como registro do processo.

A entrega avaliável é a pasta [`agencia/`](agencia/), escrita em Python com Flask, junto do frontend em [`frontend/`](frontend/).

---

## ⚙️ Instalação e Execução

O ICEIBank roda em **4 terminais simultâneos**: um para cada uma das três agências, mais um para o frontend. Essa separação não é detalhe de execução, é a essência do projeto: cada agência é um processo independente, com sua própria memória e seu próprio relógio lógico.

| Terminal | O que roda      | Porta |
| :------: | --------------- | :---: |
|    1     | Agência 0       | 4035  |
|    2     | Agência 1       | 4036  |
|    3     | Agência 2       | 4037  |
|    4     | Frontend (Vite) | 5173  |

### Pré-requisitos

- **Python 3.10+** (o projeto foi desenvolvido com o 3.14)
- **Node.js 22+** e npm, para o frontend
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

Cada terminal deve imprimir a agência e a porta em que está ouvindo, por exemplo `[Agência 0] ouvindo na porta 4035`. Deixe os três abertos: eles precisam ficar rodando ao mesmo tempo para que as transferências entre agências funcionem.

> No Windows, o Firewall do Windows Defender pode pedir permissão de rede na primeira execução de cada agência. Clique em **Permitir acesso**.

Se preferir não abrir três terminais, existe um script auxiliar que sobe as três de uma vez, com a saída de cada uma identificada por cor:

```bash
# macOS e Linux
./.venv/bin/python iniciar.py
```

```powershell
# Windows (PowerShell)
.\.venv\Scripts\python iniciar.py
```

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

### 🕒 Linha do tempo unificada

Depois de gerar alguns eventos, é possível ver a ordenação por relógio de Lamport das três agências juntas:

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

### 🧯 Problemas comuns

| Sintoma                                                       | Causa provável                                     | Solução                                                                              |
| ------------------------------------------------------------- | -------------------------------------------------- | ------------------------------------------------------------------------------------ |
| A agência não sobe e reclama de `JWT_SECRET_KEY`              | O arquivo `.env` não foi criado                    | Copie o `.env.example` para `.env` na pasta `agencia`                                |
| `Address already in use` ao subir uma agência                 | A porta já está ocupada por uma execução anterior  | Encerre o processo antigo ou reinicie o terminal                                     |
| Todas as telas mostram "não foi possível falar com a agência" | Alguma agência não está rodando                    | Confirme que os três terminais estão ativos                                          |
| As contas sumiram depois de reiniciar                         | Comportamento esperado: as contas ficam em memória | Recrie as contas entrando como `admin`                                               |
| "Já existe um usuário com esse nome" após reiniciar           | Os usuários são salvos em arquivo, e não somem     | Use outro nome, ou apague `agencia/data/usuarios.json` para voltar apenas ao `admin` |

---

## 🔌 Endpoints da API

Todas as rotas, exceto o login, exigem o cabeçalho `Authorization: Bearer <token>`.

| Método | Rota                           | Proteção         | Descrição                                         |
| :----: | ------------------------------ | ---------------- | ------------------------------------------------- |
| `POST` | `/auth/login`                  | pública          | Autentica e devolve o token JWT                   |
| `POST` | `/usuarios`                    | gerente          | Cadastra um novo correntista                      |
| `POST` | `/contas`                      | gerente          | Abre uma conta na agência responsável pelo número |
| `GET`  | `/contas/<id>`                 | dono ou gerente  | Consulta o saldo de uma conta                     |
| `POST` | `/contas/<id>/depositar`       | dono ou gerente  | Credita um valor                                  |
| `POST` | `/contas/<id>/sacar`           | dono ou gerente  | Debita um valor                                   |
| `POST` | `/transferencias`              | dono ou gerente  | Transfere, resolvendo local ou entre agências     |
| `GET`  | `/extrato`                     | autenticado      | ⭐ Extrato consolidado das três agências          |
| `POST` | `/contas/<id>/creditar-remoto` | token de serviço | Rota interna: crédito vindo de outra agência      |
| `GET`  | `/interno/contas/<usuario>`    | token de serviço | Rota interna: contas de um usuário nesta agência  |

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
│   │   │   ├── contas_controller.py
│   │   │   ├── transferencias_controller.py
│   │   │   ├── usuarios_controller.py
│   │   │   └── extrato_controller.py # ⭐ Funcionalidade adicional
│   │   ├── services/
│   │   │   ├── relogio_lamport.py    # As três regras do relógio lógico
│   │   │   ├── registro_eventos.py   # Log de eventos em JSON Lines
│   │   │   ├── auth_service.py       # Emissão e validação dos tokens
│   │   │   └── repositorio_usuarios.py
│   │   └── middlewares/
│   │       └── auth_middleware.py    # requer_autenticacao, requer_admin, requer_servico
│   ├── data/                         # Logs de eventos e usuários (não versionados)
│   ├── mesclar_logs.py               # Linha do tempo unificada das 3 agências
│   ├── iniciar.py                    # Sobe as 3 agências de uma vez
│   └── requirements.txt
│
├── frontend/                         # ✅ Entrega: interface web em Vue
│   ├── src/
│   │   ├── app/                      # Inicialização, rotas e guards
│   │   ├── modules/                  # auth, accounts, transfers, home, schemas
│   │   ├── shared/                   # Componentes, stores, serviços e layout
│   │   └── style.css                 # Design system com tokens de cor
│   └── package.json
│
├── agencia-express/                  # 📖 Referência em Node.js do roteiro (não entregue)
├── evidencias/sprint1/               # Prints de todos os testes realizados
├── enunciado/                        # Roteiro da sprint
├── RESPOSTAS.md                      # Respostas conceituais e decisões de design
└── README.md
```

---

## 🖼️ Evidências

Todos os testes foram executados e registrados em [`evidencias/sprint1/`](evidencias/sprint1/), com a data visível no terminal para comprovar a execução.

**Backend e conceitos distribuídos**

| Evidência                                                                                 | O que demonstra                                                |
| ----------------------------------------------------------------------------------------- | -------------------------------------------------------------- |
| [`transferencia-local.png`](evidencias/sprint1/transferencia-local.png)                   | Transferência dentro da mesma agência                          |
| [`transferencia-entre-agencias.png`](evidencias/sprint1/transferencia-entre-agencias.png) | Transferência entre agências, com o crédito remoto             |
| [`falha-conhecida.png`](evidencias/sprint1/falha-conhecida.png)                           | Agência de destino fora do ar: HTTP 502 e débito não revertido |
| [`linha-do-tempo.png`](evidencias/sprint1/linha-do-tempo.png)                             | Eventos das 3 agências ordenados por relógio de Lamport        |

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

**Funcionalidade adicional**

| Evidência                                                                         | O que demonstra                                                                                            |
| --------------------------------------------------------------------------------- | ---------------------------------------------------------------------------------------------------------- |
| [`funcionalidade-adicional.png`](evidencias/sprint1/funcionalidade-adicional.png) | Cada agência conhece só a sua partição, e uma única chamada ao `/extrato` reúne as três com o saldo somado |

---

## 📖 Referências

- LAMPORT, Leslie. _Time, Clocks, and the Ordering of Events in a Distributed System._ Communications of the ACM, v. 21, n. 7, 1978.
- COULOURIS, George et al. _Distributed Systems: Concepts and Design._ 5th ed. Addison-Wesley, 2011.
- TANENBAUM, A. S.; VAN STEEN, M. _Sistemas Distribuídos: Princípios e Paradigmas._ Tradução da 2ª edição. Pearson, 2007.
- MARTIN, Robert C. _Arquitetura Limpa: o guia do artesão para estrutura e design de software._ Alta Books, 2019.
- JONES, M.; BRADLEY, J.; SAKIMURA, N. _RFC 7519 - JSON Web Token (JWT)._ IETF, 2015. Disponível em: <https://datatracker.ietf.org/doc/html/rfc7519>
- Flask. Documentação oficial. Disponível em: <https://flask.palletsprojects.com/>
- Vue.js. Documentação oficial. Disponível em: <https://vuejs.org/>
- PyJWT. Documentação oficial. Disponível em: <https://pyjwt.readthedocs.io/>

---

## 🤖 Uso Responsável de IA

Seguindo a nota de transparência do próprio [`sprint-01.md`](enunciado/sprint-01.md), registro aqui, de forma aberta, como usei ferramentas de inteligência artificial neste trabalho. As ferramentas foram o **Claude Code (modelo Claude Sonnet 5)** e o **ChatGPT**, no modelo gratuito atualmente disponível (**GPT-5.6 Luna**).

**Onde a IA foi usada.** Diferente de um uso apenas cosmético, ela participou do desenvolvimento em três frentes: na implementação da **API em Flask**, na construção do **frontend em Vue**, e na redação deste `README.md` e do [`RESPOSTAS.md`](RESPOSTAS.md). Prefiro declarar isso com clareza a minimizar o papel que a ferramenta teve.

**Como foi usada.** O que separa um uso responsável de uma cópia irrefletida é o método, e aqui ele foi deliberado:

- **Engenharia de prompt.** Cada solicitação partiu de um contexto construído por mim: o enunciado da sprint, o padrão de arquitetura que eu queria seguir, as restrições do projeto e o comportamento esperado. Não descrevi problemas de forma vaga esperando uma solução pronta.
- **Direção das decisões de projeto.** As escolhas estruturais foram minhas, e várias contrariaram a primeira sugestão da ferramenta. Defini o modelo de credenciais e de papéis, o formato do armazenamento do token, a decisão de não repassar o token de sessão entre agências, o desenho da funcionalidade adicional e a identidade visual do frontend. Em mais de um momento revertí alterações que extrapolavam o escopo do roteiro, para manter a fidelidade ao que foi pedido.
- **Revisão crítica linha a linha.** Nada entrou no repositório sem leitura e entendimento. Quando o comportamento não fez sentido, questionei e corrigi: bugs de interface, mensagens de erro imprecisas e inconsistências entre o que a tela mostrava e o que a API devolvia foram identificados por mim durante os testes.
- **Validação por evidência.** Todo o comportamento documentado foi executado e comprovado por mim, e está registrado nos prints da pasta [`evidencias/sprint1/`](evidencias/sprint1/).

**O que continua sendo meu.** A compreensão do problema, as decisões de arquitetura, a validação de cada funcionalidade, a análise dos resultados observados nos logs e o conteúdo conceitual das respostas do [`RESPOSTAS.md`](RESPOSTAS.md), embasado nas referências bibliográficas listadas acima e no próprio roteiro.

Assumo integralmente a autoria e a responsabilidade por este trabalho e **estou apto a explicar e defender qualquer trecho entregue neste repositório**, seja o algoritmo do relógio de Lamport, o fluxo de autenticação e autorização, a comunicação entre as agências ou qualquer decisão tomada no frontend.

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
