defmodule EctoMigrateCapture.Repo.Migrations.ObanVersion10 do
  use Ecto.Migration

  def up do
    Oban.Migration.up(version: 10)
  end

  def down do
    Oban.Migration.down(version: 10)
  end
end
