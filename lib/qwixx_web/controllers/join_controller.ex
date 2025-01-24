defmodule QwixxWeb.JoinController do
  use QwixxWeb, :controller

  alias Qwixx.GameServer

  def join(conn, %{"name" => name, "code" => gs} = _params) do
    gs = String.upcase(gs)

    if rejoin?(conn, gs, name) do
      redirect(conn, to: ~p"/games/#{gs}")
    else
      case GameServer.add_player(gs, name) do
        {:ok, _game} ->
          conn
          |> put_session(:name, name)
          |> put_session(:gs, gs)
          |> redirect(to: ~p"/games/#{gs}")

        {:error, err} ->
          conn
          |> put_flash(:error, err)
          |> redirect(to: ~p"/")
      end
    end
  end

  def rejoin?(conn, gs, name) do
    session_name = get_session(conn, :name)
    session_gs = get_session(conn, :gs)

    with true <- session_gs == gs,
         true <- session_name == name,
         {:ok, game} <- GameServer.get_game(gs) do
      Map.has_key?(game.players, session_name)
    else
      _ -> false
    end
  end
end
