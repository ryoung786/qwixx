defmodule Qwixx.GameServer do
  use GenServer, restart: :transient
  alias Qwixx.Game
  require Logger

  def start_link(code), do: GenServer.start_link(__MODULE__, code, name: via_tuple(code))

  def new_game_server(code) do
    DynamicSupervisor.start_child(Qwixx.GameSupervisor, {__MODULE__, code})
  end

  def delete_game_server(code) do
    case game_pid(code) do
      pid when is_pid(pid) ->
        DynamicSupervisor.terminate_child(Qwixx.GameSupervisor, pid)

      nil ->
        :ok
    end
  end

  def add_player(code, name), do: call(code, {:add_player, name})

  ## Server

  @impl true
  def handle_call({:add_player, name}, _from, %Game{} = game) do
    game = Game.add_player(game, name)
    {:reply, {:ok, game.players}, game}
  end

  ## Callbacks

  @impl true
  def init(_code), do: {:ok, %{game: %Game{}}}

  defp game_pid(code) do
    code
    |> via_tuple()
    |> GenServer.whereis()
  end

  defp call(code, command) do
    case game_pid(code) do
      pid when is_pid(pid) -> GenServer.call(pid, command)
      nil -> {:error, :game_not_found}
    end
  end

  defp cast(code, command) do
    case game_pid(code) do
      pid when is_pid(pid) -> GenServer.cast(pid, command)
      nil -> {:error, :game_not_found}
    end
  end

  defp via_tuple(code), do: {:via, Registry, {Qwixx.GameRegistry, code}}
end
