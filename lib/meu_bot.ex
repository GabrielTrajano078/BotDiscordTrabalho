defmodule MeuBot do
  @moduledoc """
  Ponto de entrada da aplicação e supervisor principal.
  """

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MeuBot.Reminders,
      MeuBot.Consumer
    ]

    opts = [strategy: :one_for_one, name: MeuBot.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
