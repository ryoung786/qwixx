defmodule QwixxWeb.Plugs.RequireGame do
  @moduledoc false
  use QwixxWeb, :verified_routes

  import Phoenix.Component
  import Phoenix.LiveView

  alias Qwixx.GameServer

  def init(default), do: default

  def call(%Plug.Conn{params: %{"code" => code}} = conn, _opts) do
    if code == String.upcase(code) do
      case GameServer.get_game(code) do
        {:error, :game_not_found} -> conn |> Phoenix.Controller.redirect(to: ~p"/") |> Plug.Conn.halt()
        game -> Plug.Conn.assign(conn, :game, game)
      end
    else
      new_path = String.replace(conn.request_path, "/#{code}", "/#{String.upcase(code)}")
      conn |> Phoenix.Controller.redirect(to: new_path) |> Plug.Conn.halt()
    end
  end

  def on_mount(:default, %{"code" => code} = _params, _session, socket) do
    case GameServer.get_game(code) do
      {:error, :game_not_found} -> {:halt, redirect(socket, to: ~p"/")}
      game -> {:cont, assign(socket, game: game, gs: code)}
    end
  end
end
