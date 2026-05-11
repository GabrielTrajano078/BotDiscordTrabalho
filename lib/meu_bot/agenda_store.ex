defmodule MeuBot.AgendaStore do
  @moduledoc """
  Cria e mantém `priv/agenda.json` com lista `items` (persistência em disco).
  """

  @default %{"items" => []}

  defp path do
    Application.get_env(:meu_bot, :agenda_path) ||
      Path.join(:code.priv_dir(:meu_bot), "agenda.json")
  end

  @doc "Garante que o ficheiro existe com estrutura inicial `{\"items\": []}`."
  def ensure_file do
    p = path()

    case File.exists?(p) do
      true ->
        {:ok, :already_there}

      false ->
        p |> Path.dirname() |> File.mkdir_p!()
        File.write(p, Jason.encode!(@default))
        {:ok, :created}
    end
  end

  @doc "Lê a lista de itens (lista vazia se ficheiro inválido ou inexistente — após ensure fica ok)."
  def read_items do
    path()
    |> File.read()
    |> case do
      {:ok, ""} ->
        []

      {:ok, raw} ->
        case Jason.decode(raw) do
          {:ok, %{"items" => items}} when is_list(items) -> items
          {:ok, _} -> []
          {:error, _} -> []
        end

      {:error, :enoent} ->
        []

      {:error, _} ->
        []
    end
  end

  @doc "Substitui a lista completa no JSON."
  def write_items(items) when is_list(items) do
    p = path()
    p |> Path.dirname() |> File.mkdir_p!()
    File.write(p, Jason.encode!(%{"items" => items}))
  end

  @doc "Acrescenta um item ao início da lista (garante ficheiro antes)."
  def append_item(text) when is_binary(text) and text != "" do
    {:ok, _} = ensure_file()

    updated = [String.trim(text) | read_items()]
    write_items(updated)
    :ok
  end
end
