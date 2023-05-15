defmodule EctoMigrateCapture.Repo.Migrations.ObanVersion8 do
  use Ecto.Migration

  def up do
    Oban.Migration.up(version: 8)
  end

  def down do
    Oban.Migration.down(version: 8)
  end
end
