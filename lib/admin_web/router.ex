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
end
