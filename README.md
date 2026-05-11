
# MeuBot (Discord + Elixir + Nostrum)

Bot para a disciplina de Programação Funcional (T300): sete comandos, Tesla + Jason, OTP (supervisor + GenServer) e persistência em JSON via `MeuBot.Store`.

## Pré-requisitos

- Elixir e Erlang instalados (`elixir --version` ≥ 1.14)
- Token de bot do Discord (portal de desenvolvedores)

## Configuração do token

Não commite o token. Use variável de ambiente (recomendado):

```bash
export DISCORD_BOT_TOKEN="seu_token_aqui"
```

O `config/config.exs` lê `System.get_env("DISCORD_BOT_TOKEN")` para o Nostrum.

Opcional: caminho do arquivo de lembretes (padrão: `priv/reminders.json` relativo ao projeto, definido em `config/config.exs`).

## Executar

```bash
cd BotDiscord
mix deps.get
mix run --no-halt
```

Convide o bot ao servidor com os escopos de mensagens adequados e envie os comandos em um canal de texto.

## Comandos (distribuição do enunciado)

Prefixo **`?`** (não `!`, para não misturar com os exemplos do professor).

| Comando | Tipo | API(s) |
|--------|------|--------|
| `?conselho` | sem parâmetro | ZenQuotes (zenquotes.io) |
| `?filme <número>` | um parâmetro | swapi.tech (films) |
| `?pokemon <nome>` | um parâmetro | pokeapi.co |
| `?cambio <valor> <de> <para>` | três argumentos | open.er-api.com |
| `?repo <dono> <repo>` | dois argumentos | GitHub REST |
| `?anotar <texto>` / `?anotacoes` | persistência JSON | arquivo local (`MeuBot.Store`) |
| `?personagem <id>` | encadeamento | swapi.tech (pessoa → planeta) |

## Estrutura de módulos

- `MeuBot` — aplicação e supervisor
- `MeuBot.Consumer` — eventos Discord + pattern matching nos comandos
- `MeuBot.Commands` — uma função pública por comando
- `MeuBot.Store` — leitura/escrita do JSON
- `MeuBot.Reminders` — GenServer que mantém a lista e sincroniza com o disco

## Uso de IA generativa

Se você usou ChatGPT / Cursor / etc., o curso pede um PDF com prompts e respostas — gere e anexe na entrega, e garanta que você entende cada linha do código para a arguição.
