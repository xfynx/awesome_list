defmodule AwesomeList.Repo.Presenter do
  @moduledoc """
  Задача этого модуля - подготовка данных из БД к отдаче через контроллеры.
  """

  alias AwesomeList.Repo
  alias AwesomeList.Repo.{Languages, Libraries, Categories}
  import Ecto.Query

  @doc """
  Список записей языков в формате:
  ```
  [
    %{name: name, id: id, repo_path: path},
    # ...
  ]
  ```
  """
  @spec languages() :: list(map | nil)
  def languages do
    Languages.list_languages()
    |> Enum.map(&%{name: &1.name, id: &1.id, repo_path: &1.repo_path})
  end

  @doc """
  Список всех категорий с их библиотеками по конкретному языку.

  - `stars_count` - определяет минимальное количество звёзд у репозитория для фильтрации.
  """
  def categories_with_libs(language_id), do: categories_with_libs(language_id, 0)
  def categories_with_libs(nil, _), do: %{}
  def categories_with_libs("", _), do: %{}
  def categories_with_libs(language_id, nil), do: categories_with_libs(language_id, 0)
  def categories_with_libs(language_id, ""), do: categories_with_libs(language_id, 0)
  def categories_with_libs(language_id, stars_count) do
    from(lib in Libraries.Library)
    |> join(:inner, [lib], cat in Categories.Category, on: lib.category_id == cat.id)
    |> where([lib, cat], cat.language_id == ^language_id and lib.stars_count >= type(^stars_count, :integer))
    |> Repo.all
    |> Repo.preload([:category])
    |> Enum.group_by(& &1.category.name)
  end
end