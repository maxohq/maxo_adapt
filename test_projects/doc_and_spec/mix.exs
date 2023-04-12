defmodule Adapterized.MixProject do
  use Mix.Project

  def project do
    [
      app: :adapterized,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: [:logger, :ex_unit]
    ]
  end

  defp deps do
    [
      {:maxo_adapt, path: "../../"},
      {:dialyxir, "~> 1.0"},
      {:ex_doc, ">= 0.0.0"}
    ]
  end
end
