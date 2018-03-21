defmodule Elli.JsonGateKeeper.MixProject do
  use Mix.Project

  def project do
    [
      app: :elli_json_gate_keeper,
      version: "0.1.1",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      name: "Elli Json Gate Keeper",
      description: "A middleware that encodes and decodes JSON for Elli apps",
      package: [
        maintainers: ["Louis Pilfold"],
        licenses: ["Apache-2.0"],
        links: %{"GitHub" => "https://github.com/lpil/elli_json_gate_keeper"}
      ]
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      # Elli!
      {:elli, "~> 2.0 or ~> 3.0"},
      # JSON encoder
      {:jason, "~> 1.0"},
      # Automatic test runner
      {:mix_test_watch, "~> 0.4", [only: :dev, runtime: false]},
      # Markdown processor
      {:earmark, "~> 1.2", [only: :dev, runtime: false]},
      # Documentation generator
      {:ex_doc, "~> 0.15", [only: :dev, runtime: false]}
    ]
  end
end
