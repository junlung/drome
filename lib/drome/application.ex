defmodule Drome.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      DromeWeb.Telemetry,
      Drome.Repo,
      {DNSCluster, query: Application.get_env(:drome, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Drome.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Drome.Finch},
      # Start a worker by calling: Drome.Worker.start_link(arg)
      # {Drome.Worker, arg},
      # Start to serve requests, typically the last entry
      DromeWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Drome.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    DromeWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
