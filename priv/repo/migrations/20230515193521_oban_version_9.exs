defmodule EctoMigrateCapture.Repo.Migrations.ObanVersion9 do
  use Ecto.Migration

  def up do
    Oban.Migration.up(version: 9)
  end

  def down do
    Oban.Migration.down(version: 9)
  end
end
