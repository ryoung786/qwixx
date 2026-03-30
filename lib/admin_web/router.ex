defmodule AdminWeb.Router do
  use AdminWeb, :router
  # use ErrorTracker.Web, :router

  # import Oban.Web.Router
  import Phoenix.LiveDashboard.Router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {AdminWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :admin_basic_auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/" do
    pipe_through :browser

    live_dashboard "/dashboard",
      metrics: QwixxWeb.Telemetry

    # additional_pages: [dumper: {Dumper.LiveDashboardPage, repo: FitCal.Repo, config_module: FitCal.DumperConfig}]

    # oban_dashboard("/oban")

    # error_tracker_dashboard("/errors")

    scope "/", AdminWeb do
      live "/", HomeLive
    end
  end

  defp admin_basic_auth(conn, _opts) do
    config = Application.get_env(:qwixx, :admin_basic_auth)

    if config[:enabled] do
      Plug.BasicAuth.basic_auth(conn, username: config[:username], password: config[:password])
    else
      conn
    end
  end
end
