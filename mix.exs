defmodule Drempel.Mixfile do
  use Mix.Project

  def project do
    [
      app: :drempel,
      version: "0.1.4",
      source_url: "https://github.com/frobese/drempel",
      elixir: "~> 1.5",
      package: package(),
      description: description(),
      docs: docs(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [coveralls: :test, "coveralls.detail": :test],
      deps: deps()
    ]
  end

  def application do
    [mod: {Drempel.App, []}, applications: [:logger]]
  end

  defp package do
    [
      maintainers: ["Christian Zuckschwerdt"],
      licenses: ["MIT"],
      files: ~w(lib .formatter.exs mix.exs README.md LICENSE.txt),
      links: %{"GitHub" => "https://github.com/frobese/drempel"}
    ]
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
    [
      {:phoenix, "~> 1.3", optional: true},
      {:excoveralls, "~> 0.10", only: :test},
      {:credo, "~> 0.10", only: [:dev, :test]},
      {:earmark, "~> 1.2", only: :dev},
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end
end
