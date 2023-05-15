defmodule Mix.Tasks.Ecto.Migrate.Capture do
  use Mix.Task

  import Mix.Ecto
  import Mix.EctoSQL

  @shortdoc "Runs repository migrations with SQL capture"

  @moduledoc """
  See ecto.migrate.
  """

  @impl true
  def run(args) do
    repos = parse_repo(args)

    {:ok, _} = Application.ensure_all_started(:ecto_sql)

    EctoMigrateCapture.start_link(:migrate)

    for repo <- repos, do: EctoMigrateCapture.attach(repo, ensure_migrations_paths(repo, []))

    Mix.Task.run("ecto.migrate", args)

    for repo <- repos, do: EctoMigrateCapture.detach(repo)

    EctoMigrateCapture.save()

    :ok
  end
end
