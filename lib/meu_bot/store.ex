defmodule MeuBot.Store do
  @moduledoc """
  Leitura e escrita do arquivo JSON de lembretes (persistência entre sessões).
  """

  @default_notes []

  defp path do
    Application.get_env(:meu_bot, :store_path) ||
      Path.join(:code.priv_dir(:meu_bot), "reminders.json")
  end

  @doc "Carrega a lista de anotações do disco."
  def read_notes do
    path()
    |> File.read()
    |> case do
      {:ok, ""} ->
        @default_notes

      {:ok, raw} ->
        case Jason.decode(raw) do
          {:ok, %{"notes" => notes}} when is_list(notes) -> notes
          {:ok, _} -> @default_notes
          {:error, _} -> @default_notes
        end

      {:error, :enoent} ->
        @default_notes

      {:error, _} ->
        @default_notes
    end
  end

  @doc "Persiste a lista completa de anotações."
  def write_notes(notes) when is_list(notes) do
    path = path()
    path |> Path.dirname() |> File.mkdir_p!()

    data = Jason.encode!(%{"notes" => notes})
    File.write(path, data)
  end
end
