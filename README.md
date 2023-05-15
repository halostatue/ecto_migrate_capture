# EctoMigrateCapture

This is an example repository that partially implements what would be required
to fully capture Ecto migrations.

See [SQL Output of Migrations][] for context.

## Running

```console
$ mix deps.get
$ mix
$ mix do ecto.create, ecto.migrate.capture
$ mix do ecto.rollback.capture --all
```

[sql output of migrations]: https://groups.google.com/g/elixir-ecto/c/skQfgd9pYx0/m/Np025VIuAgAJ
