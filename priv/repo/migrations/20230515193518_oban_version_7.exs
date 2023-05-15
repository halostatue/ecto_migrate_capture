defmodule EctoMigrateCapture.Repo.Migrations.ObanVersion7 do
  use Ecto.Migration

  def up do
    Oban.Migration.up(version: 7)
  end

  def down do
    Oban.Migration.down(version: 7)
  end
end
