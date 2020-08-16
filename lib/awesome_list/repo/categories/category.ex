defmodule AwesomeList.Repo.Categories.Category do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Jason.Encoder,
    only: [
      :id,
      :name,
      :libraries
    ]
  }

  schema "categories" do
    field :name, :string
    belongs_to :language, AwesomeList.Repo.Languages.Language, on_replace: :update
    has_many :libraries, AwesomeList.Repo.Libraries.Library

    timestamps()
  end

  @doc false
  def changeset(category, attrs) do
    category
    |> cast(attrs, [:name])
    |> put_assoc(:language, attrs[:language])
    |> validate_required([:name, :language])
    |> unique_constraint([:name, :language_id])
  end
end
