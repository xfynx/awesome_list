defmodule AwesomeList.Repo.Performer do
  @moduledoc """
  Модуль содержит логику сохранения/обновления данных о категории->библиотеке.

  Для корректной работы в базе уже должны быть созданы записи `AwesomeList.Repo.Languages.Language`
  """

  alias AwesomeList.Repo.{Categories, Libraries, Languages}
  alias AwesomeList.Repo
  alias AwesomeList.Github
  alias Ecto.Changeset
  import Ecto.Query
  use GenServer
  require Logger

  # таймер запуска повторной загрузки - сутки
  @period_in_secs 60 * 60 * 24 * 1_000
  # количество параллельно выполняемых запросов в api
  @async_count 10

  # =============== API genserver
  def start_link(_) do
    Logger.info("starting #{__MODULE__}")
    GenServer.start_link(__MODULE__, %{})
  end

  def init(state) do
    schedule_work()
    {:ok, state}
  end

  def handle_info(:work, state) do
    Logger.info("AwesomeList.Repo.Performer start")

    Languages.list_languages()
    |> Enum.map(fn(lang) ->
      Task.start(fn  ->
        Logger.info("Schedule #{lang.name}'s awesome-list")
        call(lang.name)
      end)
    end)

    schedule_work()
    {:noreply, state}
  end

  defp schedule_work() do
    Process.send_after(self(), :work, @period_in_secs)
  end

  # =============== Основная логика

  @doc """
  Вызов логики модуля.

  Производится:
  - скачивание и парсинг readme
  - обогащение метаинформацией из репозиториев библиотек
  - сохранение/обновление данных в БД
  """
  def call(language_name) do
    with %Languages.Language{} = language <- Languages.get_by_name!(language_name),
         {:ok, data} <- Github.ReadmeParser.parse(language.repo_path, language.list_anchor),
         result <- enrich(data) do
      {:ok, save(language, result)}
    end
  end

  @doc """
  Функция обогащения данными результатов парсинга readme.

  На вход подаётся map результата `AwesomeList.Github.ReadmeParser.parse_readme/2`,
  на выход возвращается того же формата результат, но обогащённый: для каждой библиотеки добавляется
  метаинформация (см. `AwesomeList.Github.Repo.repo_meta/1`).

  Таким образом, данные вида:
  ```
  %{
    "Actors" => [
      {"dflow", "https://github.com/dalmatinerdb/dflow"},
      # ...
    ]
    # ...
  }
  ```
  преобразуются до вида:
  ```
  %{
    "Actors" => [
      %{
        name: "dflow",
        url: "https://github.com/dalmatinerdb/dflow",
        description: "nomatter",
        stars_count: 10,
        last_commit_at: ~N[2015-01-23 23:50:07]
      },
      # .....
    ],
    # ....
  }
  ```

  **Важно!** Загрузка метаинформации из репозиториев идёт в #{@async_count} потоков.
  """
  def enrich(data) do
    data
    |> Map.keys()
    |> Enum.map(fn(category)->
      {category, enrich_by_list(data[category])}
    end)
    |> Enum.reduce(%{}, fn({category_name, list}, result) ->
      Map.put(result, category_name, list)
    end)
  end

  defp enrich_by_list(libs) do
    libs
    |> Flow.from_enumerable(min_demand: @async_count, max_demand: @async_count+1)
    |> Flow.map(fn {name, url} ->
      case Github.Client.repo_meta(url) do
        {:ok, meta} -> Map.merge(%{name: name, url: url}, meta)
        _any -> nil
      end
    end)
    |> Enum.reject(&is_nil/1)
  end

  @doc """
  Функция создания/обновления данных о библиотеках по списку категорий для конкретного языка.

  - `language_name` - имя языка или запись из базы, коррелирует с `Language#name`
  - `categories_with_libs` - map вида:
  ```
  %{
    "Actors" => [
      %{
        name: "dflow",
        url: "https://github.com/dalmatinerdb/dflow",
        description: "nomatter",
        stars_count: 10,
        last_commit_at: ~N[2015-01-23 23:50:07]
      },
      # .....
    ],
    # ....
  }
  ```
  """
  def save(%Languages.Language{} = language, categories_with_libs) do
    categories_with_libs
    |> Map.keys()
    |> Enum.map(&create_or_update(language, &1, categories_with_libs[&1]))
  end
  def save(language_name, categories_with_libs) do
    language = Languages.get_by_name!(language_name)
    save(language, categories_with_libs)
  end

  defp create_or_update(language, category_name, libs_list) do
    case Categories.get_by_name(language.id, category_name) do
      nil -> create_category(language, category_name, libs_list)
      category -> update_category(category, libs_list)
    end
  end

  # создание категории с библиотекам
  defp create_category(%Languages.Language{} = language, category_name, libs_list) do
    Categories.create_category(%{
      name: category_name,
      language: language,
      libraries: wrap_libs_to_changesets(libs_list)
    })
  end

  # обновление категории с библиотекам.
  # тут ещё и удаление неотмеченных библиотек.
  # TODO вся эта логика с удалением либо должна быть заменена на метки, а не реальное удаление, либо проводиться в транзакции.
  # TODO есть смысл сразу удалять/помечать пустые категории, а не фильтровать их дальше
  defp update_category(%Categories.Category{} = category, libs_list) do
    ids_to_hold = libs_list
                  |> Enum.map(&Libraries.insert_or_update!(category, &1))
                  |> Enum.map(& &1.id)

    from(l in Libraries.Library, where: l.category_id == ^category.id and l.id not in ^ids_to_hold) |> Repo.delete_all
  end

  # конвертируем map с инфой о библиотеке в changeset
  defp wrap_libs_to_changesets(libs_list), do: Enum.map(libs_list, &Changeset.change(%Libraries.Library{}, &1))
end