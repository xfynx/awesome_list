defmodule AwesomeList.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false
  @env Mix.env()

  use Application

  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      AwesomeList.Repo,
      # Start the PubSub system
      {Phoenix.PubSub, name: AwesomeList.PubSub},
      # Start the Endpoint (http/https)
      AwesomeListWeb.Endpoint,
      AwesomeList.Github.RateLimitsGuard,
    ]
    children = if @env != :test do
      [AwesomeList.Repo.Performer | children]
    else
      children
    end

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AwesomeList.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    AwesomeListWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
