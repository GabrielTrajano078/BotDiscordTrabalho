defmodule MeuBot.Reminders do
  @moduledoc """
  GenServer que mantém os lembretes em memória e sincroniza com `MeuBot.Store`.
  """

  use GenServer

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def add(text), do: GenServer.call(__MODULE__, {:add, text})
  def list(), do: GenServer.call(__MODULE__, :list)

  @impl true
  def init(_opts) do
    {:ok, %{notes: MeuBot.Store.read_notes()}}
  end

  @impl true
  def handle_call({:add, text}, _from, %{notes: notes} = state) do
    updated = [text | notes]

    case MeuBot.Store.write_notes(updated) do
      :ok -> {:reply, :ok, %{state | notes: updated}}
      {:error, r} -> {:reply, {:error, r}, state}
    end
  end

  def handle_call(:list, _from, state) do
    {:reply, state.notes, state}
  end
end
