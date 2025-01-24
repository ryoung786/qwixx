defmodule QwixxWeb.DemoLive do
  @moduledoc false
  use QwixxWeb, :live_view

  import QwixxWeb.Components
  import SaladUI.Button

  alias Qwixx.GameServer

  @impl true
  def render(%{live_action: :index} = assigns) do
    ~H|<.button phx-click="new-game">hello</.button>|
  end

  @impl true
  def render(%{live_action: :game} = assigns) do
    ~H"""
    <.dice dice={@game.dice} highlight={@game.status} />
    <br />
    <div class="relative rounded bg-gray-200 p-2">
      <.scorecard scorecard={@game.players["A"]} player_name="A" />
      <.icon
        :if={@game.turn_order |> List.first() == "A"}
        name="hero-arrow-right"
        class="absolute top-1/2 -left-8 bg-red-500"
      />
    </div>
    <br />
    <div class="relative rounded bg-gray-200 p-2">
      <.scorecard scorecard={@game.players["B"]} player_name="B" />
      <.icon
        :if={@game.turn_order |> List.first() == "B"}
        name="hero-arrow-right"
        class="absolute top-1/2 -left-8 bg-red-500"
      />
    </div>
    <.templates />
    """
  end

  @impl true
  def handle_params(%{"game_server" => gs}, _uri, socket) do
    dbg(socket.assigns)
    game = GameServer.get_game(gs)
    socket = assign(socket, gs: gs, game: game)
    {:noreply, socket}
  end

  def handle_params(_params, _uri, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_event("new-game", _, socket) do
    gs = GameServer.new_game_server()
    Phoenix.PubSub.subscribe(Qwixx.PubSub, "game:#{gs}")
    GameServer.add_player(gs, "A")
    GameServer.add_player(gs, "B")
    GameServer.start_game(gs)
    {:noreply, push_patch(socket, to: "/demo/#{gs}")}
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
