defmodule Qwixx.GameServer do
  use GenServer, restart: :transient
  alias Qwixx.Game
  require Logger

  def start_link(code), do: GenServer.start_link(__MODULE__, code, name: via_tuple(code))

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
