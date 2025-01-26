defmodule QwixxWeb.MultiplayerLive do
  @moduledoc false
  use QwixxWeb, :live_view

  alias Qwixx.GameServer
  alias QwixxWeb.Component.Dialog

  @impl true
  def mount(%{"code" => gs}, %{"name" => player_name}, socket) do
    if connected?(socket), do: Phoenix.PubSub.subscribe(Qwixx.PubSub, "game:#{gs}")
    {:ok, socket |> assign(gs: gs, player_name: player_name) |> push_event("init", socket.assigns.game)}
  end

  @impl true
  def handle_event("mark", params, socket) do
    gs = socket.assigns.gs
    %{"name" => name, "color" => color, "num" => num} = params
    color = String.to_existing_atom(color)

    socket =
      case GameServer.mark(gs, name, color, num) do
        {:ok, _game} -> socket
        {:error, err} -> put_flash(socket, :error, err)
      end

    {:noreply, socket}
  end

  def handle_event("pass", %{"name" => player_name}, socket) do
    gs = socket.assigns.gs

    socket =
      case GameServer.pass(gs, player_name) do
        {:ok, _game} -> socket
        {:error, err} -> put_flash(socket, :error, err)
      end

    {:noreply, socket}
  end

  def handle_event("start-game", _params, socket) do
    if socket.assigns.game.status == :awaiting_start,
      do: GameServer.start_game(socket.assigns.gs)

    {:noreply, socket}
  end

  def handle_event("roll", _params, socket) do
    GameServer.roll(socket.assigns.gs, socket.assigns.player_name)
    {:noreply, socket}
  end

  @impl true
  def handle_info(%Qwixx.PubSub.Msg{} = msg, socket) do
    {:noreply, push_event(socket, "game-events", msg.game)}
  end
end
