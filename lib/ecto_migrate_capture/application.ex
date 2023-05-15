defmodule EctoMigrateCapture.Application do
  def start(_type, _args) do
    Supervisor.start_link(
      [
        EctoMigrateCapture.Repo
      ],
      strategy: :one_for_one,
      name: EctoMigrateCapture.Supervisor
    )
  end
end
