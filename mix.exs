defmodule Stories.MixProject do
  use Mix.Project

  def project do
    [
      app: :stories,
      version: "0.1.5",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Hex
      description: "An Elixir wrapper for the Stories API, by Clockk.com Inc.",
      package: [
        maintainers: ["Eric Froese", "Clockk.com Inc."],
        licenses: ["closed"],
        links: %{
          "GitHub" => "https://github.com/clockkcom/stories",
          "Clockk.com" => "https://clockk.com"
        }
      ],

      # Docs
      name: "Stories",
      source_url: "https://github.com/clockkcom/stories",
      homepage_url: "https://github.com/clockkcom/stories",
      docs: [
        # The main page in the docs
        main: "Stories",
        extras: ["README.md"]
      ]
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
      {:httpoison, "~> 1.6"},
      {:jason, "~> 1.1"},
      {:exvcr, "~> 0.10", only: :test},
      {:ex_doc, "~> 0.21", only: :dev, runtime: false}
    ]
  end
end
