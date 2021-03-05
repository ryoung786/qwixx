defmodule Qwixx.GameSupervisor do
  @moduledoc """
  Dynamically starts a game server
  """
  use DynamicSupervisor
  alias Qwixx.GameServer

  def start_link(_arg) do
    DynamicSupervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end

  @spec start_game(String.t()) :: {:ok, pid()} | {:error, {:already_started, pid()}}
  def start_game(code) do
    DynamicSupervisor.start_child(__MODULE__, {GameServer, code})
  end

  @spec stop_game(String.t()) :: :ok
  def stop_game(game_id) do
    case Qwixx.GameServer.game_pid(game_id) do
      pid when is_pid(pid) ->
        DynamicSupervisor.terminate_child(__MODULE__, pid)

      nil ->
        :ok
    end
  end

  def which_children(), do: Supervisor.which_children(__MODULE__)
end
