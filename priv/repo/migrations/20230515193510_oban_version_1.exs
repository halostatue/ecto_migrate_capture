defmodule EctoMigrateCapture.Repo.Migrations.ObanVersion1 do
  use Ecto.Migration

  def up do
    Oban.Migration.up(version: 1)
  end

  def down do
    Oban.Migration.down(version: 1)
  end
end
