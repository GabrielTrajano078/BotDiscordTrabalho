defmodule MeuBot.Consumer do
  @moduledoc """
  Recebe eventos do Discord e despacha comandos com pattern matching.
  Prefixo dos comandos: **?** (evita colisão com exemplos do professor que usam `!`).
  """

  use Nostrum.Consumer

  alias Nostrum.Api.Message

  def handle_event({:MESSAGE_CREATE, %{author: %{bot: true}}, _}), do: :ok

  def handle_event({:MESSAGE_CREATE, msg, _ws_state}) do
    msg.content
    |> String.trim()
    |> dispatch(msg.channel_id)

    :ok
  end

  def handle_event(_), do: :ok

  defp dispatch("?conselho", ch), do: send_result(ch, MeuBot.Commands.conselho())

  defp dispatch("?anotacoes", ch), do: send_result(ch, MeuBot.Commands.anotacoes())

  defp dispatch("?filme", ch), do: Message.create(ch, "> Uso: ?filme <número>  ex: ?filme 1")

  defp dispatch("?pokemon", ch), do: Message.create(ch, "> Uso: ?pokemon <nome>  ex: ?pokemon pikachu")

  defp dispatch("?cambio", ch),
    do: Message.create(ch, "> Uso: ?cambio <valor> <de> <para>  ex: ?cambio 100 USD BRL")

  defp dispatch("?repo", ch),
    do: Message.create(ch, "> Uso: ?repo <dono> <repo>  ex: ?repo elixir-lang elixir")

  defp dispatch("?anotar", ch), do: Message.create(ch, "> Uso: ?anotar <texto>")

  defp dispatch("?personagem", ch),
    do: Message.create(ch, "> Uso: ?personagem <número>  ex: ?personagem 1")

  defp dispatch("?filme " <> id, ch) do
    send_result(ch, MeuBot.Commands.filme(String.trim(id)))
  end

  defp dispatch("?pokemon " <> nome, ch) do
    send_result(ch, MeuBot.Commands.pokemon(String.trim(nome)))
  end

  defp dispatch("?cambio " <> resto, ch) do
    partes = resto |> String.trim() |> String.split(~r/\s+/, trim: true)

    case partes do
      [valor, de, para] -> send_result(ch, MeuBot.Commands.cambio(valor, de, para))
      _ -> Message.create(ch, "> Uso: ?cambio <valor> <de> <para>")
    end
  end

  defp dispatch("?repo " <> resto, ch) do
    partes = resto |> String.trim() |> String.split(~r/\s+/, trim: true)

    case partes do
      [dono, repo] -> send_result(ch, MeuBot.Commands.repo(dono, repo))
      _ -> Message.create(ch, "> Uso: ?repo <dono> <repo>  (dois nomes, sem espaços extra)")
    end
  end

  defp dispatch("?anotar " <> texto, ch) do
    send_result(ch, MeuBot.Commands.anotar(texto))
  end

  defp dispatch("?personagem " <> id, ch) do
    send_result(ch, MeuBot.Commands.personagem(String.trim(id)))
  end

  # Exemplos típicos do enunciado com `!` — lembrar que aqui o prefixo é `?`.
  defp dispatch("!ping" <> _, ch), do: comandos_novos(ch)
  defp dispatch("!cep" <> _, ch), do: comandos_novos(ch)
  defp dispatch("!clima" <> _, ch), do: comandos_novos(ch)
  defp dispatch("!conv" <> _, ch), do: comandos_novos(ch)
  defp dispatch("!wiki" <> _, ch), do: comandos_novos(ch)
  defp dispatch("!lembrar" <> _, ch), do: comandos_novos(ch)
  defp dispatch("!lembretes" <> _, ch), do: comandos_novos(ch)
  defp dispatch("!curiosidade" <> _, ch), do: comandos_novos(ch)

  # Se alguém repetir os nomes com `!` em vez de `?`.
  defp dispatch("!conselho" <> _, ch), do: prefixo_errado(ch)
  defp dispatch("!anotacoes" <> _, ch), do: prefixo_errado(ch)
  defp dispatch("!filme" <> _, ch), do: prefixo_errado(ch)
  defp dispatch("!pokemon" <> _, ch), do: prefixo_errado(ch)
  defp dispatch("!cambio" <> _, ch), do: prefixo_errado(ch)
  defp dispatch("!repo" <> _, ch), do: prefixo_errado(ch)
  defp dispatch("!anotar" <> _, ch), do: prefixo_errado(ch)
  defp dispatch("!personagem" <> _, ch), do: prefixo_errado(ch)

  defp dispatch(_, _), do: :ok

  defp prefixo_errado(channel_id) do
    Message.create(
      channel_id,
      "> Este bot usa **`?`** no início do comando (não `!`). " <>
        "Ex.: `?conselho`, `?filme 1`, `?pokemon pikachu`."
    )
  end

  defp comandos_novos(channel_id) do
    Message.create(
      channel_id,
      "> Comandos de exemplo com **`!`** (ping, cep, clima, …) são do material do professor; **este bot não os implementa**.\n" <>
        "> Aqui o prefixo é **`?`**: `?conselho` · `?filme 1` · `?pokemon pikachu` · " <>
        "`?cambio 100 USD BRL` · `?repo elixir-lang elixir` · `?anotar ...` / `?anotacoes` · `?personagem 1`"
    )
  end

  defp send_result(channel_id, {:ok, texto}), do: Message.create(channel_id, texto)
  defp send_result(channel_id, {:error, motivo}), do: Message.create(channel_id, "> #{motivo}")
end
