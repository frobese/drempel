defmodule Drempel.Mixfile do
  use Mix.Project

  def project do
    [app: :drempel,
     version: "0.1.0",
     source_url: "https://github.com/frobese/drempel",
     elixir: "~> 1.2",
     package: package,
     description: description,
     docs: docs,
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: ["coveralls": :test, "coveralls.detail": :test],
     deps: deps]
  end

  def application do
    [mod: {Drempel.App, []},
     applications: [:logger]]
  end

  defp package do
    [maintainers: ["Christian Zuckschwerdt"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/frobese/drempel"}]
  end

  defp description do
    """
    Drempel provides exponential backoffs to put speed bumps on your critical
    actions to e.g. slow down brute force attacks.
    """
  end

  defp docs do
    [extras: ["README.md"]]
  end

  defp deps do
    [{:excoveralls, "~> 0.5", only: :test},
     {:credo, "~> 0.3", only: [:dev, :test]},
     {:dogma, "~> 0.1", only: :dev},
     {:earmark, "~> 0.2", only: :dev},
     {:ex_doc, "~> 0.11", only: :dev}]
  end
end
