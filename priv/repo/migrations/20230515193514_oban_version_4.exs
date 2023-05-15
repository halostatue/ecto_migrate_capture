defmodule EctoMigrateCapture.Repo.Migrations.ObanVersion4 do
  use Ecto.Migration

  def up do
    Oban.Migration.up(version: 4)
  end

  def down do
    Oban.Migration.down(version: 4)
  end
end
