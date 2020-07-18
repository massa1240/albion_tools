defmodule AlbionTools.MixProject do
  use Mix.Project

  def project do
    [
      app: :albion_tools,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      escript: [main_module: AlbionTools.CLI],
      deps: deps()
    ]
  end

  def application do
    [
      mod: {AlbionTools.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp deps do
    [
      {:phoenix_ecto, "~> 4.0"},
      {:postgrex, ">= 0.0.0"},
      {:ecto_sql, "~> 3.1"},
      {:artificery, "~> 0.4.3"},
      {:poison, "~> 3.1"},
      {:jason, "~> 1.0"},
      {:table_rex, "~> 3.0.0"},
      {:httpoison, "~> 1.6"}
    ]
  end
end
