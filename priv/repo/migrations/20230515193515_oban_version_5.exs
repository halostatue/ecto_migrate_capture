defmodule EctoMigrateCapture.Repo.Migrations.ObanVersion5 do
  use Ecto.Migration

  def up do
    Oban.Migration.up(version: 5)
  end

  def down do
    Oban.Migration.down(version: 5)
  end
end
