defmodule EctoMigrateCapture.Repo.Migrations.ObanVersion2 do
  use Ecto.Migration

  def up do
    Oban.Migration.up(version: 2)
  end

  def down do
    Oban.Migration.down(version: 2)
  end
end
