defmodule Provider.MixProject do
  use Mix.Project

  def project do
    [
      app: :provider,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      compilers: extra_compilers() ++ Mix.compilers(),
      boundary: [externals_mode: :strict]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:boundary, "~> 0.8", runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test]},
      {:ecto, "~> 3.7"},
      {:ex_doc, "~> 0.25.1", only: :dev},
      {:dialyxir, "~> 1.1", only: [:dev, :test]}
    ]
  end

  defp aliases do
    [
      credo: ~w/compile credo/
    ]
  end

  defp extra_compilers(), do: if(Mix.env() == :prod, do: [], else: [:boundary])
end
