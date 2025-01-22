defmodule QwixxWeb.MultiplayerLive do
  @moduledoc false
  use QwixxWeb, :live_view

  import QwixxWeb.Components

  alias Qwixx.GameServer

  @impl true
  def handle_params(%{"code" => gs}, _uri, socket) do
    socket = assign(socket, gs: gs, player_name: "A")
    {:noreply, socket}
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

  @impl true
  def handle_event("pass", %{"name" => player_name}, socket) do
    gs = socket.assigns.gs

    socket =
      case GameServer.pass(gs, player_name) do
        {:ok, _game} -> socket
        {:error, err} -> put_flash(socket, :error, err)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_info(%Qwixx.PubSub.Msg{} = msg, socket) do
    {:noreply, push_event(socket, "game-events", msg.game)}
  end
end
