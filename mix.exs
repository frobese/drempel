defmodule Drempel.Mixfile do
  use Mix.Project

  def project do
    [app: :drempel,
     version: "0.1.1",
     source_url: "https://github.com/active-group/drempel",
     elixir: "~> 1.7",
     package: package(),
     description: description(),
     docs: docs(),
     test_coverage: [tool: ExCoveralls],
     preferred_cli_env: [coveralls: :test, "coveralls.detail": :test],
     deps: deps()]
  end

  def application do
    [mod: {Drempel.App, []},
     applications: [:logger]]
  end

  defp package do
    [maintainers: ["Simon Schulz", "Tim Digel"],
     licenses: ["MIT"],
     links: %{"GitHub" => "https://github.com/active-group/drempel"}]
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
    [{:phoenix, "~> 1.3", optional: true},
     {:excoveralls, "~> 0.10", only: :test},
     {:credo, "~> 0.10", only: [:dev, :test]},
     {:dogma, "~> 0.1", only: :dev},
     {:earmark, "~> 1.2", only: :dev},
     {:ex_doc, "~> 0.19", only: :dev}]
  end
end
