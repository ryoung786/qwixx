defmodule QwixxWeb.SessionController do
  use QwixxWeb, :controller

  def join(conn, %{"code" => code, "name" => name}) do
    game_path = Routes.game_path(conn, :index, code)

    conn
    |> put_session(:code, code)
    |> put_session(:name, name)
    |> redirect(to: game_path)
  end

  def leave(conn, _params) do
    homepage_path = Routes.page_path(conn, :index)

    conn
    |> clear_session()
    |> redirect(to: homepage_path)
  end
end
