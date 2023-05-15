defmodule EctoMigrateCapture.Repo do
  use Ecto.Repo, otp_app: :ecto_migrate_capture, adapter: Ecto.Adapters.Postgres
end
