---
title: "Registro de uso de ferramentas de IA generativa"
subtitle: "Projeto MeuBot — Bot Discord (Elixir / Nostrum) — T300"
author: "Gabriel Trajano"
date: "10 de maio de 2026"
lang: pt-BR
---

# Declaração

Declaro, para fins de cumprimento às normas da disciplina **Programação Funcional (T300)** da Unifor, que **parte substancial deste trabalho foi elaborada com o auxílio de ferramenta de inteligência artificial generativa** (assistente de código no **Cursor**, com modelo de linguagem tipo GPT/Claude), conforme permitido pelo regulamento da atividade, desde que haja **transparência** e **registro dos prompts e respostas**.

Assumo **integral responsabilidade** pelo código entregue, incluindo testes, configuração do ambiente, execução do bot no Discord e capacidade de **explicar, em arguição oral, qualquer trecho** da implementação (consumer, comandos, GenServer, persistência JSON, chamadas HTTP/Tesla, etc.).

---

# Prompt 1 *(contexto: enunciado em imagens + pasta do projeto vazia)*

**Texto enviado pelo estudante:**  
*(Mensagem de texto vazia; o ambiente anexou as capturas de tela do PDF do professor com requisitos do bot: Elixir, Nostrum, sete comandos, Tesla/HTTPoison, Jason, OTP, GenServer, módulos `MeuBot`, `MeuBot.Consumer`, `MeuBot.Commands`, `MeuBot.Store`, persistência em JSON, comando encadeando duas APIs, README, token por variável de ambiente, etc.)*

**Resposta da IA *(resumo fiel do que foi produzido)*:**

- Verificou que a pasta do projeto estava vazia e que não havia `mix` no PATH local; criou o projeto **manualmente** (arquivos `mix.exs`, `config/`, `lib/`, `.gitignore`, `README.md`).
- Definiu o aplicativo **`MeuBot`** com supervisor e filhos **`MeuBot.Reminders`** (GenServer que sincroniza lembretes com disco) e **`MeuBot.Consumer`** (Nostrum).
- Implementou **`MeuBot.Store`**: leitura/escrita de `priv/reminders.json` com Jason, tratando arquivo ausente ou JSON inválido.
- Implementou **`MeuBot.Commands`** com Tesla + adapter Hackney, uma função pública por comando:
  - `!ping` — API uselessfacts;
  - `!clima` — wttr.in;
  - `!cep` — ViaCEP;
  - `!conv` — Frankfurter;
  - `!wiki` — Wikipedia opensearch;
  - `!lembrar` / `!lembretes` — persistência via GenServer + Store;
  - `!curiosidade` — encadeamento Open-Meteo (geocode) → REST Countries.
- Implementou **`MeuBot.Consumer`** com pattern matching em `dispatch/2` sobre o conteúdo da mensagem.
- Documentou no **README** variável `DISCORD_BOT_TOKEN`, `mix deps.get`, `mix run --no-halt`, tabela de comandos e lembrete sobre PDF de IA e arguição.
- Validou compilação com **Docker** (`hexpm/elixir`) após ajuste de versão do Hackney em `mix.exs`.

**Observação:** A resposta completa da IA na conversa é **longa** (muitos tokens), incluindo trechos de código e explicações em português. O repositório com o código e o histórico do Cursor complementam a evidência do processo.

---

# Prompt 2

**Texto enviado pelo estudante:**

> agora faca o pdf para entregar, igual aquele do CLI que voce tinha feito, dizendo que fez com ia

**Resposta da IA *(esta entrega)*:**

- Produção deste arquivo **`registro_uso_ia_meu_bot.md`** com declaração formal, registro dos prompts conhecidos e resumos das respostas.
- Geração do **PDF** correspondente para anexar no AVA junto ao link do repositório.

---

# Ferramenta utilizada

| Campo | Valor |
|-------|--------|
| Produto | Cursor (editor + agente de IA) |
| Uso | Geração e revisão de código Elixir, estrutura do projeto, README e este registro |
| Data (aprox.) | 10/05/2026 |

---

# Como reproduzir o PDF a partir deste arquivo

No diretório `documentacao/` do projeto:

```bash
cd documentacao
docker run --rm --platform linux/amd64 -w /data -v "$(pwd):/data" pandoc/latex:3.1.1 \
  registro_uso_ia_meu_bot.md -o registro_uso_ia_meu_bot.pdf
```

*(Em Mac Apple Silicon use `--platform linux/amd64` se a imagem for amd64.)*

Alternativa: abrir o `.md` no Cursor e exportar/imprimir como PDF.
