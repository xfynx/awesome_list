defmodule AwesomeList.Repo.Libraries.Library do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Jason.Encoder,
    only: [
      :id,
      :name,
      :description,
      :last_commit_at,
      :stars_count,
      :url,
    ]
  }

  schema "libraries" do
    field :description, :string
    field :last_commit_at, :naive_datetime
    field :name, :string
    field :stars_count, :integer
    field :url, :string
    belongs_to :category, AwesomeList.Repo.Categories.Category, on_replace: :update

    timestamps()
  end

  @doc false
  def changeset(library, attrs) do
    library
    |> cast(attrs, [:name, :url, :last_commit_at, :stars_count, :description])
    |> put_assoc(:category, attrs[:category])
    |> validate_required([:name, :url, :category])
#    |> unique_constraint([:name, :category_id])
#    |> unique_constraint(:url)
  end
end
