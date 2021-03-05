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

  def pop(code) do
    GenServer.call(game_pid(code), :pop)
  end

  ## Callbacks

  @impl true
  def init(_code), do: {:ok, %{game: %Game{}}}

  def game_pid(code) do
    code
    |> via_tuple()
    |> GenServer.whereis()
  end

  defp via_tuple(code), do: {:via, Registry, {Qwixx.GameRegistry, code}}
end
