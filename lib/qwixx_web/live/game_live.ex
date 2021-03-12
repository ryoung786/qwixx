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
    {:ok, game} = GameServer.start_game(socket.assigns.code)
    {:noreply, assign(socket, game: game)}
  end

  @impl true
  def handle_info({:put_flash, key, msg}, socket) do
    msg = if is_list(msg), do: hd(msg), else: msg
    {:noreply, put_flash(socket, key, msg)}
  end
end
