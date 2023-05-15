defmodule Mix.Tasks.Ecto.Rollback.Capture do
  use Mix.Task

  import Mix.Ecto
  import Mix.EctoSQL

  @shortdoc "Rolls back repository migrations with SQL capture"

  @moduledoc """
  See ecto.rollback.
  """

  @impl true
  def run(args) do
    repos = parse_repo(args)

    {:ok, _} = Application.ensure_all_started(:ecto_sql)

    EctoMigrateCapture.start_link(:rollback)

    for repo <- repos, do: EctoMigrateCapture.attach(repo, ensure_migrations_paths(repo, []))

    Mix.Task.run("ecto.rollback", args)

    for repo <- repos, do: EctoMigrateCapture.detach(repo)

    EctoMigrateCapture.save()

    :ok
  end
end
