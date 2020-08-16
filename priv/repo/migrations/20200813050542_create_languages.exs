defmodule AwesomeList.Repo.Migrations.CreateLanguages do
  use Ecto.Migration

  def change do
    create table(:languages) do
      add :name, :string
      add :repo_path, :string
      add :list_anchor, :string

      timestamps()
    end

    create unique_index(:languages, [:name])
    create unique_index(:languages, [:repo_path])
  end
end
