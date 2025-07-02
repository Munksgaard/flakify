defmodule Flakify.MixProject do
  use Mix.Project

  @version "0.1.0"
  @scm_url "https://github.com/Munksgaard/flakify"
  @elixir_requirement "~> 1.18"

  def project do
    [
      app: :flakify,
      version: @version,
      elixir: @elixir_requirement,
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      package: [
        maintainers: [
          "Philip Munksgaard"
        ],
        licenses: ["MIT"],
        links: %{"GitHub" => @scm_url},
        files: ~w(lib mix.exs README.md)
      ],
      source_url: @scm_url,
      docs: docs(),
      description: """
      Sets up a Nix flake-based development environment for your Elixir/Phoenix project.
      """
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:igniter, "~> 0.6", optional: true},
      {:ex_doc, "~> 0.24", only: :dev}
    ]
  end

  defp docs do
    [
      source_url_pattern: "#{@scm_url}/blob/v#{@version}/%{path}#L%{line}",
      main: "readme",
      extras: ["README.md"]
    ]
  end
end
