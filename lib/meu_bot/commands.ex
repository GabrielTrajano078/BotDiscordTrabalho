defmodule MeuBot.Commands do
  @moduledoc """
  Uma função pública por comando do bot; helpers privados com `|>` e APIs distintas.
  """

  alias MeuBot.Reminders

  @doc "Sem parâmetros — citação aleatória (zenquotes.io, JSON)."
  def conselho do
    client()
    |> Tesla.get("https://zenquotes.io/api/random")
    |> map_citacao_response()
  end

  @doc "Um parâmetro — ficha curta de filme Star Wars por id (swapi.tech)."
  def filme(id_str) when is_binary(id_str) and id_str != "" do
    id = String.trim(id_str)

    if id =~ ~r/^\d+$/ do
      client()
      |> Tesla.get("https://www.swapi.tech/api/films/#{id}")
      |> map_filme_response()
    else
      {:error, "Use só o número do episódio: ?filme 1"}
    end
  end

  def filme(_), do: {:error, "Uso: ?filme <número>  ex: ?filme 1"}

  @doc "Um parâmetro — dados básicos de um Pokémon (pokeapi.co)."
  def pokemon(nome) when is_binary(nome) and nome != "" do
    slug =
      nome
      |> String.trim()
      |> String.downcase()
      |> String.replace(~r/\s+/, "-")

    client()
    |> Tesla.get("https://pokeapi.co/api/v2/pokemon/#{slug}")
    |> map_pokemon_response(String.trim(nome))
  end

  def pokemon(_), do: {:error, "Uso: ?pokemon <nome>  ex: ?pokemon pikachu"}

  @doc "Três tokens — câmbio (open.er-api.com, base = moeda de origem)."
  def cambio(amount_str, from, to)
      when is_binary(amount_str) and is_binary(from) and is_binary(to) do
    with {:ok, amount} <- parse_amount(amount_str),
         from_u <- String.upcase(String.trim(from)),
         to_u <- String.upcase(String.trim(to)) do
      url = "https://open.er-api.com/v6/latest/#{from_u}"

      client()
      |> Tesla.get(url)
      |> map_cambio_response(amount, from_u, to_u)
    end
  end

  def cambio(_, _, _), do: {:error, "Uso: ?cambio <valor> <de> <para>  ex: ?cambio 100 USD BRL"}

  @doc "Dois argumentos — dados públicos de repositório (GitHub API)."
  def repo(owner, name)
      when is_binary(owner) and is_binary(name) and owner != "" and name != "" do
    o = String.trim(owner)
    n = String.trim(name)
    path = o <> "/" <> n

    client()
    |> Tesla.get("https://api.github.com/repos/#{path}")
    |> map_github_response()
  end

  def repo(_, _), do: {:error, "Uso: ?repo <dono> <repo>  ex: ?repo elixir-lang elixir"}

  @doc "Persistência — salva via GenServer + JSON."
  def anotar(texto) when is_binary(texto) and texto != "" do
    case Reminders.add(String.trim(texto)) do
      :ok -> {:ok, "> Anotado!"}
      {:error, r} -> {:error, "Não consegui salvar: #{inspect(r)}"}
    end
  end

  def anotar(_), do: {:error, "Uso: ?anotar <texto>"}

  @doc "Persistência — lista via GenServer (dados do JSON)."
  def anotacoes do
    lista = Reminders.list() |> Enum.reverse()
    {:ok, "> Suas anotações: #{inspect(lista, charlists: :as_lists)}"}
  end

  @doc "Encadeia pessoa (swapi.tech) + planeta natal (segundo GET)."
  def personagem(id_str) when is_binary(id_str) and id_str != "" do
    id = id_str |> String.trim()

    with true <- id =~ ~r/^\d+$/,
         {:ok, pessoa} <- fetch_swapi_person(id),
         {:ok, texto} <- planeta_resumo(pessoa) do
      {:ok, texto}
    else
      false -> {:error, "Use um número: ?personagem <id>  ex: ?personagem 1"}
      {:error, _} = e -> e
      _ -> {:error, "Não achei esse personagem."}
    end
  end

  def personagem(_), do: {:error, "Uso: ?personagem <id>  ex: ?personagem 1"}

  defp client do
    Tesla.client(
      [
        Tesla.Middleware.FollowRedirects,
        Tesla.Middleware.JSON,
        {Tesla.Middleware.Headers,
         [
           {"user-agent", "MeuBot/0.1 (educacional)"},
           {"accept", "application/json"}
         ]}
      ],
      {Tesla.Adapter.Hackney, recv_timeout: 20_000}
    )
  end

  defp map_citacao_response({:ok, %{status: 200, body: [%{"q" => q, "a" => a} | _]}})
       when is_binary(q) do
    autor = if is_binary(a) and a != "", do: " — #{a}", else: ""
    {:ok, "> «#{q}»#{autor}"}
  end

  defp map_citacao_response({:ok, %{status: 200, body: body}}),
    do: {:error, "Citação: formato inesperado #{inspect(body, limit: 100)}"}

  defp map_citacao_response({:ok, %{status: s, body: b}}),
    do: {:error, "zenquotes HTTP #{s} #{inspect(b, limit: 80)}"}

  defp map_citacao_response({:error, r}), do: {:error, inspect(r)}

  defp map_filme_response({:ok, %{status: 200, body: %{"message" => "ok", "result" => res}}}) do
    props = Map.get(res, "properties", %{})

    titulo = Map.get(props, "title", "?")
    diretor = Map.get(props, "director", "?")
    data = Map.get(props, "release_date", "?")

    {:ok, "> **#{titulo}** — direção: #{diretor} — estreia: #{data}."}
  end

  defp map_filme_response({:ok, %{status: 404}}), do: {:error, "Filme não encontrado."}

  defp map_filme_response({:ok, %{status: s, body: b}}),
    do: {:error, "Filme HTTP #{s}: #{inspect(b, limit: 80)}"}

  defp map_filme_response({:error, r}), do: {:error, inspect(r)}

  defp map_pokemon_response({:ok, %{status: 200, body: b}}, pedido) when is_map(b) do
    nome = b["name"] || pedido
    alt_dm = b["height"]
    peso_hg = b["weight"]
    metros = pokemon_meters(alt_dm)
    kg = pokemon_kg(peso_hg)
    tipos = get_in(b, ["types"]) || []

    labels =
      tipos
      |> Enum.map(fn
        %{"type" => %{"name" => t}} -> t
        _ -> nil
      end)
      |> Enum.reject(&is_nil/1)
      |> Enum.join(", ")

    {:ok,
     "> **#{nome}** (pedido: «#{pedido}») — ~#{metros} m, ~#{kg} kg. Tipos: #{labels || "?"}"}
  end

  defp map_pokemon_response({:ok, %{status: 404}}, _),
    do: {:error, "Pokémon não encontrado na PokeAPI."}

  defp map_pokemon_response({:ok, %{status: s, body: b}}, _),
    do: {:error, "PokeAPI HTTP #{s}: #{inspect(b, limit: 80)}"}

  defp map_pokemon_response({:error, r}, _), do: {:error, inspect(r)}

  defp pokemon_meters(h) when is_integer(h), do: Float.round(h / 10.0, 1)
  defp pokemon_meters(_), do: "?"

  defp pokemon_kg(w) when is_integer(w), do: Float.round(w / 10.0, 1)
  defp pokemon_kg(_), do: "?"

  defp map_cambio_response({:ok, %{status: 200, body: body}}, amount, from_u, to_u)
       when is_map(body) do
    case body do
      %{"result" => "success", "rates" => rates} when is_map(rates) ->
        case rates[to_u] do
          nil ->
            {:error, "Moeda destino #{to_u} não encontrada (origem #{from_u})."}

          mult ->
            out = amount * mult
            {:ok, "> #{amount} #{from_u} ≈ #{Float.round(out, 2)} #{to_u} (cotação open.er-api.com)."}
        end

      _ ->
        {:error, "Câmbio: resposta inesperada #{inspect(body, limit: 100)}"}
    end
  end

  defp map_cambio_response({:ok, %{status: s, body: b}}, _, _, _),
    do: {:error, "Câmbio HTTP #{s}: #{inspect(b, limit: 80)}"}

  defp map_cambio_response({:error, r}, _, _, _), do: {:error, inspect(r)}

  defp map_github_response({:ok, %{status: 200, body: b}}) when is_map(b) do
    nome = b["full_name"] || "?"
    stars = b["stargazers_count"] || 0
    desc = b["description"] || "sem descrição"

    {:ok, "> **#{nome}** — #{stars} estrelas\n> #{desc}"}
  end

  defp map_github_response({:ok, %{status: 404}}), do: {:error, "Repositório não encontrado."}

  defp map_github_response({:ok, %{status: s, body: b}}),
    do: {:error, "GitHub HTTP #{s}: #{inspect(b, limit: 120)}"}

  defp map_github_response({:error, r}), do: {:error, inspect(r)}

  defp parse_amount(str) do
    case Float.parse(String.trim(str)) do
      {n, _} -> {:ok, n}
      :error -> {:error, "Valor numérico inválido."}
    end
  end

  defp fetch_swapi_person(id) do
    case Tesla.get(client(), "https://www.swapi.tech/api/people/#{id}") do
      {:ok, %{status: 200, body: %{"message" => "ok", "result" => %{"properties" => props}}}} ->
        {:ok, props}

      {:ok, %{status: 404}} ->
        {:error, "Personagem não encontrado."}

      {:ok, %{status: s, body: b}} ->
        {:error, "SWAPI pessoa HTTP #{s}: #{inspect(b, limit: 80)}"}

      {:error, r} ->
        {:error, inspect(r)}
    end
  end

  defp planeta_resumo(%{"name" => n} = props) do
    case props["homeworld"] do
      nil ->
        {:ok, "> **#{n}** — sem planeta natal na API."}

      url when is_binary(url) ->
        case Tesla.get(client(), url) do
          {:ok, %{status: 200, body: %{"result" => %{"properties" => %{"name" => pn}}}}} ->
            {:ok, "> **#{n}** — planeta natal: **#{pn}**."}

          {:ok, %{status: 200, body: %{"result" => %{"properties" => p}}}} ->
            nome_p = Map.get(p, "name", "?")
            {:ok, "> **#{n}** — planeta natal: **#{nome_p}**."}

          {:ok, %{status: s}} ->
            {:error, "Planeta HTTP #{s}."}

          {:error, r} ->
            {:error, inspect(r)}
        end
    end
  end

  defp planeta_resumo(_), do: {:error, "Resposta de personagem inválida."}
end
