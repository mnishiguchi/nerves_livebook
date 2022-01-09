defmodule NervesLivebook.Database do
  @moduledoc """
  The database for this application. It uses [CubDB] file-based database.

  [CubDB]: https://hexdocs.pm/cubdb/CubDB.html

  ## Examples

      # Start a server when the application starts.
      children = [
        {CubDB, [data_dir: "/data/database", name: NervesLivebook.Database]},
      ]

      alias NervesLivebook.Database

      # For DB operations, use CubDB functions.
      CubDB.get(Database, :feeling)
      CubDB.put(Database, :feeling, "awesome")
      CubDB.delete(Database, :feeling)

  """
end
