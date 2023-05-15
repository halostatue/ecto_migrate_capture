defmodule EctoMigrateCapture.MixProject do
  use Mix.Project

  def project do
    [
      app: :ecto_migrate_capture,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
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
      {:ecto, "~> 3.10"},
      {:ecto_sql, "~> 3.10",
       github: "halostatue/ecto_sql",
       branch: "add-migration-module-telemetry-span",
       override: true},
      {:oban, "~> 2.15"},
      {:postgrex, "~> 0.17.0"},
      {:ecto_dev_logger, "~> 0.9"}
    ]
  end
end
