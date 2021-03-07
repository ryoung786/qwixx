defmodule QwixxWeb.GameLive do
  use QwixxWeb, :live_view
  alias Qwixx.GameServer

  @impl true
  def mount(%{"code" => code}, %{"name" => name}, socket) do
    game = GameServer.get_game(code)
    {:ok, assign(socket, game: game, name: name, code: code)}
  end
end
