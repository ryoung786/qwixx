defmodule QwixxWeb.Components.Scorecard do
  use QwixxWeb, :live_component
  alias Qwixx.GameServer
  alias Qwixx.Scorecard
  alias Qwixx.ScorecardRow, as: Row

  @impl true
  def handle_event("mark", %{"color" => color, "number" => num}, socket) do
    %{code: code, name: name} = socket.assigns

    with {:ok, game} <- GameServer.mark(code, name, color, num) do
      {:noreply, assign(socket, game: game)}
    else
      {:error, err} -> {:noreply, put_flash(socket, :info, err)}
    end
  end

  @impl true
  def handle_event("pass", _params, socket) do
    %{code: code, name: name} = socket.assigns.code
    {:ok, game} = GameServer.pass(code, name)
    {:noreply, assign(socket, game: game)}
  end
end
