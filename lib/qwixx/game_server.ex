defmodule Qwixx.GameServer do
  @moduledoc false
  use GenServer, restart: :transient

  alias Qwixx.Game
  alias Qwixx.PubSub.Msg

  require Logger

  defmodule State do
    @moduledoc false
    defstruct code: nil, game: nil
  end

  def start_link(code), do: GenServer.start_link(__MODULE__, code, name: via_tuple(code))

  def new_game_server do
    code = generate_code()

    case start_server_process(code) do
      {:ok, _pid} -> code
      {:error, {:already_started, _}} -> new_game_server()
    end
  end

  defp start_server_process(code) do
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
  def remove_player(code, name), do: call(code, {:remove_player, name})
  def roll(code, name), do: call(code, {:roll, name})
  def start_game(code), do: call(code, {:start_game})
  def mark(code, name, color, num), do: call(code, {:mark, name, color, num})
  def pass(code, name), do: call(code, {:pass, name})
  def get_game(code), do: call(code, {:get_game})

  ## Server

  @impl true
  def handle_call({:add_player, name}, _from, %State{code: code, game: game} = state) do
    case Game.add_player(game, name) do
      %Game{} = game ->
        broadcast(code, game, :player_added, name)
        IO.inspect(name, label: "[player added] ")
        {:reply, {:ok, game.players}, %{state | game: game}}

      {:error, msg} ->
        IO.inspect(msg, label: "[error] ")
        {:reply, {:error, msg}, state}
    end
  end

  def handle_call({:remove_player, name}, _from, %State{code: code, game: game} = state) do
    case Game.remove_player(game, name) do
      %Game{} = game ->
        broadcast(code, game, :player_removed, name)
        {:reply, {:ok, game.players}, %{state | game: game}}

      error ->
        {:reply, error, state}
    end
  end

  def handle_call({:start_game}, _from, %State{code: code, game: game} = state) do
    game = Game.start(game)
    broadcast(code, game, :game_started)
    {:reply, {:ok, game}, %{state | game: game}}
  end

  def handle_call({:mark, name, color, num}, _from, %State{code: code, game: game} = state) do
    case Game.mark(game, name, color, num) do
      %Game{} = game ->
        broadcast(code, game, :mark, %Msg.Mark{player_name: name, color: color, number: num})
        {:reply, {:ok, game}, %{state | game: game}}

      {:error, msg} ->
        {:reply, {:error, msg}, state}
    end
  end

  def handle_call({:pass, name}, _from, %State{code: code, game: game} = state) do
    case Game.pass(game, name) do
      %Game{} = game ->
        broadcast(code, game, :pass, name)
        {:reply, {:ok, game}, %{state | game: game}}

      {:error, msg} ->
        {:reply, {:error, msg}, state}
    end
  end

  def handle_call({:get_game}, _from, %State{game: game} = state) do
    {:reply, game, state}
  end

  def handle_call({:roll, name}, _from, %State{code: code, game: game} = state) do
    case Game.roll(game, name) do
      %Game{} = game ->
        broadcast(code, game, :roll, name)
        {:reply, {:ok, game}, %{state | game: game}}

      {:error, msg} ->
        {:reply, {:error, msg}, state}
    end
  end

  def handle_call(catchall, _from, %State{game: game} = state) do
    IO.inspect(catchall, label: "[catchall] ")
    {:reply, game, state}
  end

  ## Callbacks

  @impl true
  def init(code), do: {:ok, %State{code: code, game: %Game{}}}

  def game_pid(code), do: code |> via_tuple() |> GenServer.whereis()

  defp call(code, command) do
    case game_pid(code) do
      pid when is_pid(pid) -> GenServer.call(pid, command)
      nil -> {:error, :game_not_found}
    end
  end

  defp broadcast(code, game, event, data \\ nil) do
    IO.inspect({event, data}, label: "[xxx] broadcasting")

    Phoenix.PubSub.broadcast(Qwixx.PubSub, "game:#{code}", %Msg{
      event: event,
      data: data,
      game: game
    })
  end

  defp generate_code do
    "ABCDEFGHJKMNPQRSTUVWXYZ"
    |> String.graphemes()
    |> Enum.shuffle()
    |> Enum.take(4)
    |> Enum.join()
  end

  defp via_tuple(code), do: {:via, Registry, {Qwixx.GameRegistry, code}}
end
