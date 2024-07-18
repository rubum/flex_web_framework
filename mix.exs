defmodule Flex.MixProject do
  use Mix.Project

  @version "0.1.0"
  @source_url "https://github.com/rubum/flex"

  def project do
    [
      app: :flex_web,
      version: @version,
      elixir: "~> 1.12",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),
      description: description(),
      package: package(),
      docs: docs(),
      name: "Flex",
      source_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger, :plug_cowboy],
      mod: {Flex.Application, []}
    ]
  end

  defp deps do
    [
      {:plug_cowboy, "~> 2.5"},
      {:jason, "~> 1.2"},
      {:file_system, "~> 0.2"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false}
    ]
  end

  defp aliases do
    [
      "flex.server": ["flex.server"],
      "flex.prod": ["flex.prod"]
    ]
  end

  defp description do
    "Flex is a lightweight, Flask-inspired web framework for Elixir."
  end

  defp package do
    [
      name: "flex_web",
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/rubum/flex"},
      files: ~w(lib priv .formatter.exs mix.exs README* LICENSE* CHANGELOG*),
    ]
  end

  defp docs do
    [
      main: "readme",
      name: "Flex",
      source_ref: "v#{@version}",
      canonical: "http://hexdocs.pm/flex_web",
      source_url: @source_url,
      extras: ["README.md", "CHANGELOG.md"]
    ]
  end
end
