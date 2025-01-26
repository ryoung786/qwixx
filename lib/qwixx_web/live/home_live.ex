defmodule QwixxWeb.HomeLive do
  @moduledoc false
  use QwixxWeb, :live_view

  alias Qwixx.GameServer
  alias QwixxWeb.Component.Dialog
  alias QwixxWeb.Component.Form

  embed_templates "home/*"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}), show_modal?: false)}
  end

  @impl true
  def handle_event("new-game", %{"name" => name}, socket) do
    gs = GameServer.new_game_server()
    {:noreply, redirect(socket, to: ~p"/games/#{gs}/join/session?name=#{name}")}
  end
end
