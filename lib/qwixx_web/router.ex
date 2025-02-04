defmodule QwixxWeb.Router do
  use QwixxWeb, :router

  alias QwixxWeb.Plugs.RequireGame

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {QwixxWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :game do
    plug RequireGame
  end

  scope "/", QwixxWeb do
    pipe_through :browser

    live "/", HomeLive, :home

    live "/scorecard", ScorecardLive, :index
    live "/demo", DemoLive, :index
    live "/demo/:game_server", DemoLive, :game
  end

  scope "/games/:code", QwixxWeb do
    pipe_through [:browser, :game]

    live_session :default, on_mount: RequireGame do
      live "/", MultiplayerLive
      live "/join", JoinLive
      get "/join/session", JoinController, :join
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", QwixxWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard in development
  if Application.compile_env(:qwixx, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: QwixxWeb.Telemetry
      live "/playground", QwixxWeb.PlaygroundLive
    end
  end
end
