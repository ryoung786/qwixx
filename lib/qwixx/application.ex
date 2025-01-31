defmodule Qwixx.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      QwixxWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:qwixx, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Qwixx.PubSub},
      {Registry, keys: :unique, name: Qwixx.GameRegistry},
      {DynamicSupervisor, name: Qwixx.GameSupervisor, strategy: :one_for_one},
      TwMerge.Cache,
      # Start a worker by calling: Qwixx.Worker.start_link(arg)
      # {Qwixx.Worker, arg},
      # Start to serve requests, typically the last entry
      QwixxWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Qwixx.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    QwixxWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
