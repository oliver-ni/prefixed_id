defmodule PrefixedID.MixProject do
  use Mix.Project

  @source_url "https://github.com/oliver-ni/prefixed_id"

  def project do
    [
      app: :prefixed_id,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      description: "UUIDv7-backed human-readable IDs for Ecto",
      deps: deps(),
      package: package(),
      docs: docs(),
      source_url: @source_url
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp package do
    [
      maintainers: ["Oliver Ni"],
      licenses: ["MPL-2.0"],
      links: %{"GitHub" => @source_url}
    ]
  end

  defp deps do
    [
      {:rustler, "~> 0.33.0"},
      {:ecto, "~> 3.11"},
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "readme",
      extras: ["README.md", "LICENSE"]
    ]
  end
end
