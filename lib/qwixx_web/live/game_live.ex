defmodule QwixxWeb.GameLive do
  use QwixxWeb, :live_view
  alias Qwixx.GameServer
  alias QwixxWeb.Components.Scorecard, as: ScorecardComponent
  alias QwixxWeb.Components.Dice, as: DiceComponent

  @impl true
  def mount(%{"code" => code}, %{"name" => name}, socket) do
    game = GameServer.get_game(code)
    {:ok, assign(socket, game: game, name: name, code: code)}
  end

  @impl true
  def handle_event("start_game", _params, socket) do
    GameServer.start_game(socket.assigns.code)
    {:noreply, socket}
  end
end
