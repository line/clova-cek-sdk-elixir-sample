defmodule AirQuality.MixProject do
  use Mix.Project

  def project do
    [
      app: :air_quality,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:cowboy, :plug, :logger],
      mod: {AirQuality.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:clova, "~> 0.3.0"},
      {:cowboy, "~> 2.2"},
      {:plug, "~> 1.5"},
      {:poison, "~> 3.1"},
      {:httpoison, "~> 1.0"}
    ]
  end
end
