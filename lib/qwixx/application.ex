defmodule Qwixx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      QwixxWeb.Telemetry,
      {Phoenix.PubSub, name: Qwixx.PubSub},
      {Registry, keys: :unique, name: Qwixx.GameRegistry},
      {DynamicSupervisor, name: Qwixx.GameSupervisor, strategy: :one_for_one},
      QwixxWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Qwixx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    QwixxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
