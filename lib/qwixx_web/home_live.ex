defmodule QwixxWeb.HomeLive do
  @moduledoc false
  use QwixxWeb, :live_view

  alias Qwixx.GameServer

  embed_templates "controllers/page_html/*"

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, form: to_form(%{}), show_modal?: false)}
  end

  @impl true
  def handle_event("new-game", %{"name" => name}, socket) do
    gs = GameServer.new_game_server()
    {:noreply, redirect(socket, to: ~p"/games/#{gs}/join?name=#{name}")}
  end

  def handle_event("join-game", %{"name" => name}, socket) do
    gs = GameServer.new_game_server()
    {:noreply, redirect(socket, to: ~p"/games/#{gs}/join?name=#{name}")}
  end
end
