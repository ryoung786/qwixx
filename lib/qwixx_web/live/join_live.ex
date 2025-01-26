defmodule QwixxWeb.JoinLive do
  @moduledoc false
  use QwixxWeb, :live_view

  alias Qwixx.PubSub.Msg
  alias QwixxWeb.Component.Form

  @player_events ~w/player_added player_removed/a

  @impl true
  def mount(%{"code" => gs}, session, socket) do
    # TODO: if the session contains a gs code and a name, and that game
    # is still active and `name` is a player in that game, then prompt
    # them to rejoin that game instead.
    # Like, "You were recently in a game with A, B, and C.  Would you like to re-join that game?  "

    session_name = session["name"]
    session_gs = session["gs"]

    if session_gs == gs && session_name in Map.keys(socket.assigns.game.players) do
      {:ok, push_navigate(socket, to: ~p"/games/#{gs}")}
    else
      # subscribe to game changes to we can always check in real-time if the
      # player name input is valid against the latest
      if connected?(socket), do: Phoenix.PubSub.subscribe(Qwixx.PubSub, "game:#{gs}")
      {:ok, assign(socket, form: to_form(%{}))}
    end
  end

  @impl true
  def handle_event("submit", %{"name" => name}, socket) do
    gs = socket.assigns.gs
    errors = validate(name, Map.keys(socket.assigns.game.players))

    if Enum.empty?(errors) do
      {:noreply, redirect(socket, to: ~p"/games/#{gs}/join/session?name=#{name}")}
    else
      {:noreply, assign(socket, form: to_form(%{"name" => name}, errors: errors))}
    end
  end

  def handle_event("validate", %{"name" => name}, socket) do
    errors = validate(name, Map.keys(socket.assigns.game.players))
    {:noreply, assign(socket, form: to_form(%{"name" => name}, errors: errors))}
  end

  defp validate(name, players) do
    cond do
      name == "" -> [name: {"Can't be blank", []}]
      name in players -> [name: {"Already taken", []}]
      true -> []
    end
  end

  @impl true
  def handle_info(%Msg{event: e, game: game}, socket) when e in @player_events do
    # the list of players has changed, so we need to run validation again
    # the pushed "validate" event is handled by a Hook which just pushes a validate
    # event right back to this liveview and is handled in the handle_event("validate") fn
    {:noreply, socket |> assign(game: game) |> push_event("validate", nil)}
  end

  def handle_info(%Msg{}, socket), do: {:noreply, socket}
end
