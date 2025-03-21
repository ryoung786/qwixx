defmodule Qwixx.GameServer do
  @moduledoc false
  use GenServer, restart: :transient

  alias Qwixx.Game
  alias Qwixx.PubSub.Msg

  require Logger

  defmodule State do
    @moduledoc false
    defstruct code: nil, game: nil, timer: nil
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

  def set_almost_game_over(code), do: call(code, {:set_almost_game_over})

  ## Server

  @impl true
  def handle_call({:add_player, name}, _from, %State{code: code, game: game} = state) do
    case Game.add_player(game, name) do
      {:ok, game} ->
        broadcast(code, game, :player_added, name)
        {:reply, {:ok, game.players}, %{state | game: game}}

      {:error, msg} ->
        {:reply, {:error, msg}, state}
    end
  end

  def handle_call({:remove_player, name}, _from, %State{code: code, game: game} = state) do
    case Game.remove_player(game, name) do
      {:ok, game} ->
        broadcast(code, game, :player_removed, name)
        {:reply, {:ok, game.players}, %{state | game: game}}

      error ->
        {:reply, error, state}
    end
  end

  def handle_call({:start_game}, _from, %State{code: code, game: game} = state) do
    game = Game.start(game)
    state = reset_timer(game, state)
    broadcast(code, game, :game_started)
    {:reply, {:ok, game}, %{state | game: game}}
  end

  def handle_call({:mark, name, color, num}, _from, %State{code: code, game: game} = state) do
    case Game.mark(game, name, color, num) do
      {:ok, game} ->
        state = reset_timer(game, state)
        broadcast(code, game, :mark, %Msg.Mark{player_name: name, color: color, number: num})
        {:reply, {:ok, game}, %{state | game: game}}

      {:error, msg} ->
        {:reply, {:error, msg}, state}
    end
  end

  def handle_call({:pass, name}, _from, %State{code: code, game: game} = state) do
    case Game.pass(game, name) do
      {:ok, game} ->
        state = reset_timer(game, state)
        broadcast(code, game, :pass, name)
        {:reply, {:ok, game}, %{state | game: game}}

      {:error, msg} ->
        {:reply, {:error, msg}, state}
    end
  end

  def handle_call({:get_game}, _from, %State{game: game} = state) do
    {:reply, game, state}
  end

  def handle_call({:set_almost_game_over}, _from, %State{game: game} = state) do
    game = Qwixx.Admin.set_almost_game_over(game)
    broadcast(state.code, game, :refresh)
    {:reply, {:ok, game}, %{state | game: game}}
  end

  def handle_call({:roll, name}, _from, %State{code: code, game: game} = state) do
    case Game.roll(game, name) do
      {:ok, game} ->
        state = reset_timer(game, state)
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

  @impl true
  def handle_info(:time_expired, %State{code: code, game: game} = state) do
    IO.inspect(state.timer, label: "[xxx] Time expired!")
    {:ok, game} = Game.time_expired(game)

    state = reset_timer(game, state)
    broadcast(code, game, :time_expired)
    {:noreply, %{state | game: game}}
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

  defp reset_timer(game, state) do
    {event, _} = List.first(game.event_history)

    IO.inspect(event, label: "[xxx] reset_timer called w/event")
    IO.inspect(state.timer, label: "[xxx] current timer")
    IO.inspect(game.status, label: "[xxx] game status")

    if event == :status_changed do
      state.timer && state.timer |> Process.cancel_timer() |> IO.inspect(label: "[xxx] cancelled timer")

      timer =
        if game.timer_duration == nil,
          do: nil,
          else: Process.send_after(self(), :time_expired, game.timer_duration)

      IO.inspect(timer, label: "[xxx] set timer")

      %{state | timer: timer}
    else
      state
    end
  end
end
