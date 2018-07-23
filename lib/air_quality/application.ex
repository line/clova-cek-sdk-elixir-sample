defmodule AirQuality.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    port =
      case System.get_env("PORT") do
        nil -> 4001
        str -> String.to_integer(str)
      end

    # List all child processes to be supervised
    children = [
      {Plug.Adapters.Cowboy2, scheme: :http, plug: AirQuality.Router, options: [port: port]}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: AirQuality.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
