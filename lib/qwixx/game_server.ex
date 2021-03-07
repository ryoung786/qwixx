defmodule Qwixx.GameServer do
  use GenServer, restart: :transient
  alias Qwixx.Game
  require Logger

  def start_link(code), do: GenServer.start_link(__MODULE__, code, name: via_tuple(code))

  def new_game_server() do
    code = generate_code()

    case code |> new_game_server() do
      {:ok, _pid} -> code
      {:error, {:already_started, _}} -> new_game_server()
    end
  end

  defp new_game_server(code) do
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
  def start_game(code), do: call(code, {:start_game})
  def mark(code, name, color, num), do: call(code, {:mark, name, color, num})
  def pass(code, name), do: call(code, {:pass, name})
  def get_game(code), do: call(code, {:get_game})

  ## Server

  @impl true
  def handle_call({:add_player, name}, _from, %Game{} = game) do
    game = Game.add_player(game, name)
    {:reply, {:ok, game.players}, game}
  end

  @impl true
  def handle_call({:remove_player, name}, _from, %Game{} = game) do
    game = Game.remove_player(game, name)
    {:reply, {:ok, game.players}, game}
  end

  @impl true
  def handle_call({:start_game}, _from, %Game{} = game) do
    game = Game.start(game)
    {:reply, {:ok, game}, game}
  end

  @impl true
  def handle_call({:mark, name, color, num}, _from, %Game{} = game) do
    case Game.mark(game, name, color, num) do
      {:ok, game} -> {:reply, {:ok, game}, game}
      {:error, msg} -> {:reply, {:error, msg}, game}
    end
  end

  @impl true
  def handle_call({:pass, name}, _from, %Game{} = game) do
    case Game.pass(game, name) do
      {:ok, game} -> {:reply, {:ok, game}, game}
      {:error, msg} -> {:reply, {:error, msg}, game}
    end
  end

  @impl true
  def handle_call({:get_game}, _from, %Game{} = game) do
    {:reply, game, game}
  end

  @impl true
  def handle_call(catchall, _from, %Game{} = game) do
    IO.inspect(catchall, label: "[catchall] ")
    {:reply, game, game}
  end

  ## Callbacks

  @impl true
  def init(_code), do: {:ok, %Game{}}

  def game_pid(code) do
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

  # defp cast(code, command) do
  #   case game_pid(code) do
  #     pid when is_pid(pid) -> GenServer.cast(pid, command)
  #     nil -> {:error, :game_not_found}
  #   end
  # end

  defp generate_code() do
    "ABCDEFGHJKMNPQRSTUVWXYZ"
    |> String.graphemes()
    |> Enum.shuffle()
    |> Enum.take(4)
    |> Enum.join()
  end

  defp via_tuple(code), do: {:via, Registry, {Qwixx.GameRegistry, code}}
end
