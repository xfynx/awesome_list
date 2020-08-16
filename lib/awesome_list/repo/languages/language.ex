defmodule AwesomeList.Repo.Languages.Language do
  use Ecto.Schema
  import Ecto.Changeset

  @derive {
    Jason.Encoder,
    only: [
      :id,
      :name,
      :list_anchor,
      :repo_path,
      :categories,
    ]
  }

  schema "languages" do
    field :list_anchor, :string
    field :name, :string
    field :repo_path, :string
    has_many :categories, AwesomeList.Repo.Categories.Category

    timestamps()
  end

  @doc false
  def changeset(language, attrs) do
    language
    |> cast(attrs, [:name, :repo_path, :list_anchor])
    |> validate_required([:name, :repo_path, :list_anchor])
    |> unique_constraint(:name)
    |> unique_constraint(:repo_path)
  end
end
