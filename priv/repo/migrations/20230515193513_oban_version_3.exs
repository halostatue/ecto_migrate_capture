defmodule EctoMigrateCapture.Repo.Migrations.ObanVersion3 do
  use Ecto.Migration

  def up do
    Oban.Migration.up(version: 3)
  end

  def down do
    Oban.Migration.down(version: 3)
  end
end
