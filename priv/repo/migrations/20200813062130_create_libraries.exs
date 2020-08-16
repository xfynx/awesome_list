defmodule AwesomeList.Repo.Migrations.CreateLibraries do
  use Ecto.Migration

  def change do
    create table(:libraries) do
      add :name, :string
      add :url, :string
      add :last_commit_at, :naive_datetime
      add :stars_count, :integer, default: 0
      add :description, :text
      add :category_id, references(:categories, on_delete: :nothing)

      timestamps()
    end

    create index(:libraries, [:category_id])
    create unique_index(:libraries, [:name, :category_id])
    create unique_index(:libraries, [:url])
  end
end
