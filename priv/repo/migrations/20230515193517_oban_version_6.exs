defmodule EctoMigrateCapture.Repo.Migrations.ObanVersion6 do
  use Ecto.Migration

  def up do
    Oban.Migration.up(version: 6)
  end

  def down do
    Oban.Migration.down(version: 6)
  end
end
