defmodule AwesomeList.Repo.Libraries do
  @moduledoc """
  The Libraries context.
  """

  import Ecto.Query, warn: false
  alias AwesomeList.Repo

  alias AwesomeList.Repo.Libraries.Library
  alias AwesomeList.Repo.Categories.Category

  @doc """
  Returns the list of libraries.

  ## Examples

      iex> list_libraries()
      [%Library{}, ...]

  """
  def list_libraries do
    Repo.all(Library)
  end

  @doc """
  Gets a single library.

  Raises `Ecto.NoResultsError` if the Library does not exist.

  ## Examples

      iex> get_library!(123)
      %Library{}

      iex> get_library!(456)
      ** (Ecto.NoResultsError)

  """
  def get_library!(id), do: Repo.get!(Library, id)

  @doc """
  Creates a library.

  ## Examples

      iex> create_library(%{field: value})
      {:ok, %Library{}}

      iex> create_library(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_library(attrs \\ %{}) do
    %Library{}
    |> Library.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a library.

  ## Examples

      iex> update_library(library, %{field: new_value})
      {:ok, %Library{}}

      iex> update_library(library, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_library(%Library{} = library, attrs) do
    library
    |> Library.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a library.

  ## Examples

      iex> delete_library(library)
      {:ok, %Library{}}

      iex> delete_library(library)
      {:error, %Ecto.Changeset{}}

  """
  def delete_library(%Library{} = library) do
    Repo.delete(library)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking library changes.

  ## Examples

      iex> change_library(library)
      %Ecto.Changeset{data: %Library{}}

  """
  def change_library(%Library{} = library, attrs \\ %{}) do
    Library.changeset(library, attrs)
  end

  @doc """
  Безопасный поиск по имени
  """
  def get_by_name(category_id, name), do: Repo.get_by(Library, category_id: category_id, name: name)

  @doc """
  Найти или создать новую запись библиотеки.

  Обязательно требует наличие `attrs[:name]` для корректной работы.
  """
  def insert_or_update!(%Category{} = category, attrs) do
    attributes = Map.merge(attrs, %{category: category})

    {:ok, lib} = case get_by_name(category.id, attrs[:name]) do
      nil ->
        create_library(attributes)

      lib ->
        lib
        |> Repo.preload([:category])
        |> update_library(attributes)
    end

    lib
  end
end
