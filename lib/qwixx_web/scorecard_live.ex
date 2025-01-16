defmodule QwixxWeb.ScorecardLive do
  @moduledoc false
  use QwixxWeb, :live_view

  import QwixxWeb.Components

  alias Qwixx.Scorecard

  @impl true
  def mount(_params, _session, socket) do
    socket = assign(socket, scorecard: %Scorecard{})
    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div class="bg-gray-200 p-2 rounded relative">
      <.scorecard scorecard={@scorecard} player_name="A" />
    </div>
    """
  end

  @impl true
  def handle_event("mark", %{"color" => color, "num" => num}, socket) do
    card = socket.assigns.scorecard
    color = String.to_existing_atom(color)

    socket =
      case Scorecard.mark(card, color, num) do
        {:ok, card} -> assign(socket, scorecard: card)
        {:error, err} -> put_flash(socket, :error, err)
      end

    {:noreply, socket}
  end

  @impl true
  def handle_event("pass", _params, socket) do
    card = socket.assigns.scorecard

    socket =
      case Scorecard.pass(card) do
        {:ok, card} -> assign(socket, scorecard: card)
        {:error, err} -> put_flash(socket, :error, err)
      end

    {:noreply, socket}
  end
end
