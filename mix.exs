defmodule ElixirXmlParserBenchmark.MixProject do
  use Mix.Project

  def project do
    [
      app: :elixir_xml_parser_benchmark,
      version: "0.1.0",
      elixir: "~> 1.8",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger, :xmerl]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:fast_xml, "~> 1.1"},
      {:erlsom, "~> 1.5"},
      {:meeseeks, "~> 0.12"},
      {:saxy, "~> 0.9"},
      {:sweet_xml, "~> 0.6.6"},
      {:benchee, "~> 1.0", only: :dev},
      {:benchee_html, "~> 1.0", only: :dev}
    ]
  end
end
