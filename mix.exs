defmodule MaxoAdapt.MixProject do
  use Mix.Project
  @github_url "https://github.com/maxohq/maxo_adapt"
  @version "0.1.3"
  @description "MaxoAdapt provides fast, safe and clean adapter pattern implementation for Elixir"

  def project do
    [
      app: :maxo_adapt,
      source_url: @github_url,
      version: @version,
      description: @description,
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      test_paths: ["test", "lib"],
      test_pattern: "*_test.exs",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  def elixirc_paths(:test), do: ["lib", "test/support"]
  def elixirc_paths(_), do: ["lib"]

  defp package do
    [
      files: ~w(lib mix.exs guides README* CHANGELOG* LICENCE*),
      licenses: ["MIT"],
      links: %{
        "Github" => @github_url,
        "Changelog" => "#{@github_url}/blob/main/CHANGELOG.md"
      }
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.29", only: :dev, runtime: false},
      {:maxo_test_iex, "~> 0.1", only: [:test]},
      {:mneme, "~> 0.3", only: [:test]}
    ]
  end
end
