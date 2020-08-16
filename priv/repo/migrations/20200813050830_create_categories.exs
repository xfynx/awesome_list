defmodule AwesomeList.Repo.Migrations.CreateCategories do
  use Ecto.Migration

  def change do
    create table(:categories) do
      add :name, :string
      add :language_id, references(:languages, on_delete: :nothing)

      timestamps()
    end

    create index(:categories, [:language_id])
    create unique_index(:categories, [:name, :language_id])
  end
end
