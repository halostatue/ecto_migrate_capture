defmodule EctoMigrateCapture do
  @moduledoc """
  Collects and writes the SQL from Ecto migrations to files.
  """

  def start_link(mode) do
    Agent.start_link(fn -> %{mode: mode, repos: %{}} end, name: __MODULE__)
  end

  def attach(repo, paths) do
    prefix = repo.config()[:telemetry_prefix]

    :telemetry.attach_many(
      handler_id(prefix),
      [
        prefix ++ [:query],
        prefix ++ [:schema_migration, :start],
        prefix ++ [:schema_migration, :stop]
      ],
      &__MODULE__.telemetry_handler/4,
      []
    )

    initialize_repo_collector(repo, paths)
  end

  def save() do
    %{mode: mode, repos: repos} = Agent.get(__MODULE__, & &1)

    timestamp =
      DateTime.utc_now()
      |> DateTime.to_iso8601(:basic)
      |> to_string()
      |> String.replace(~r/^(\d{8})T(\d{6}).*$/, "\\g{1}\\g{2}")

    for {_repo, %{paths: paths, migrations: migrations}} <- repos do
      [migrations_path | _] = paths
      capture_path = Path.join([migrations_path, "#{mode}", timestamp])
      File.mkdir_p!(capture_path)

      migrations
      |> Map.keys()
      |> Enum.sort(fn
        :preamble, :preamble -> true
        :preamble, _ -> true
        _, :preamble -> false
        {v1, _}, {v2, _} -> v1 <= v2
      end)
      |> Enum.each(fn version ->
        filename =
          case version do
            :preamble ->
              "00000000000000_ecto_#{mode}_preamble.sql"

            {version, module} ->
              module_name =
                module
                |> Macro.underscore()
                |> Path.split()
                |> Enum.reverse()
                |> hd()

              "#{version}_#{module_name}.sql"
          end

        queries =
          migrations
          |> Map.fetch!(version)
          |> Enum.map(&(&1 <> ";\n"))

        File.write!(
          Path.join(capture_path, filename),
          queries
        )
      end)
    end
  end

  def detach(repo) do
    :telemetry.detach(handler_id(repo.config()[:telemetry_prefix]))
  end

  def telemetry_handler([_, _, :schema_migration, :start], _measurements, metadata, _config) do
    start_repo_migration(metadata)
  end

  def telemetry_handler([_, _, :schema_migration, :stop], _measurements, _metadata, _config) do
  end

  def telemetry_handler([_, _, :query], _measurements, metadata, _config) do
    append_migration_query(metadata)
  end

  defp format_query(query, params, _repo_adapter) when map_size(params) == 0 do
    query
  end

  defp format_query(query, params, adapter)
       when adapter in [Ecto.Adapters.Postgres, Ecto.Adapters.Tds] do
    params_by_index =
      params
      |> Enum.with_index(1)
      |> Map.new(fn {value, index} -> {index, value} end)

    placeholder_with_number_regex = placeholder_with_number_regex(adapter)

    query
    |> to_string()
    |> String.replace(placeholder_with_number_regex, fn <<_prefix::utf8, index::binary>> =
                                                          replacement ->
      case Map.fetch(params_by_index, String.to_integer(index)) do
        {:ok, value} ->
          Ecto.DevLogger.PrintableParameter.to_expression(value)

        :error ->
          replacement
      end
    end)
  end

  defp format_query(query, params, Ecto.Adapters.MyXQL) do
    params_by_index =
      params
      |> Enum.with_index()
      |> Map.new(fn {value, index} -> {index, value} end)

    query
    |> String.split("]?")
    |> Enum.map_reduce(0, fn elem, index ->
      formatted_value =
        case Map.fetch(params_by_index, index) do
          {:ok, value} ->
            Ecto.DevLogger.PrintableParameter.to_expression(value)

          :error ->
            []
        end

      {[elem, formatted_value], index + 1}
    end)
    |> elem(0)
  end

  defp placeholder_with_number_regex(Ecto.Adapters.Postgres), do: ~r/\$\d+/
  defp placeholder_with_number_regex(Ecto.Adapters.Tds), do: ~r/@\d+/

  defp handler_id(prefix) do
    [:ecto_migrate_capture_migrator] ++ prefix
  end

  defp initialize_repo_collector(repo, paths) do
    Agent.update(
      __MODULE__,
      &%{
        &1
        | repos:
            Map.put(&1.repos, repo, %{
              current_migration: :preamble,
              paths: paths,
              migrations: %{preamble: []}
            })
      }
    )
  end

  defp start_repo_migration(%{module: module, repo: repo, version: version}) do
    Agent.update(__MODULE__, fn state ->
      migration_key = {version, module}

      repo_state = Map.fetch!(state.repos, repo)

      new_migrations =
        repo_state
        |> Map.get(:migrations, %{})
        |> Map.put(migration_key, [])

      new_repo_state =
        state.repos
        |> Map.fetch!(repo)
        |> Map.put(:current_migration, migration_key)
        |> Map.put(:migrations, new_migrations)

      %{state | repos: Map.put(state.repos, repo, new_repo_state)}
    end)
  end

  defp append_migration_query(%{params: params, query: query, repo: repo}) do
    Agent.update(__MODULE__, fn state ->
      repo_state = Map.fetch!(state.repos, repo)
      current_migration = Map.fetch!(repo_state, :current_migration)

      new_migrations =
        Map.put(
          repo_state.migrations,
          current_migration,
          Map.get(repo_state.migrations, current_migration, []) ++
            [format_query(query, params, repo.__adapter__())]
        )

      new_repo_state = Map.put(repo_state, :migrations, new_migrations)

      %{state | repos: Map.put(state.repos, repo, new_repo_state)}
    end)
  end
end
