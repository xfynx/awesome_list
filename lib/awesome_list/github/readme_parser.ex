defmodule AwesomeList.Github.ReadmeParser do
  @moduledoc """
  Парсинг Readme из репозитория
  """

  alias AwesomeList.Github.Client

  @doc """
  Парсер README.md репозитория.

  Происходит попытка чтения html-страницы README.md из указанного в `repo_path` ("<имя>/<репо>") репозитория.

  Возвращается результат функции `parse_readme/2`
  """
  def parse(repo_path, anchor) do
    case Client.readme(repo_path) do
      {:ok, data} -> parse_readme(data, anchor)
      {:error, response} -> "error: #{inspect(response)}"
    end
  end

  @doc """
  Функция парсинга readme-файла.

  - `string_data` - html в виде строки
  - `anchor` - якорь, под которым перечислены все категории. от него ищем категории, от категорий - библиотеки.

  В результате возвращается tuple вида:
  ```
  {:ok, %{
    "Actors" => [
      {"dflow", "https://github.com/dalmatinerdb/dflow"},
      # .....
    ],
    "Benchmarking" => [
      {"benchee", "https://github.com/PragTob/benchee"},
      # .....
    ],
    "SMS" => [],
    # .....
  }}
  ```
  где верхнеуровневые ключи - это категории, а списки - все библиотеки в категории.
  """
  def parse_readme(string_data, anchor) do
    doc = Floki.parse_document!(string_data)
    # у нас нет селектора parent. стурктура такова, что идут на одном уровне h2/h3, p, ul.
    # нам надо найти нужный h2 или h3 и взять ближайший к нему ul, в котором будут все библиотеки из этой категории.
    # выкручиваемся посредством split по подстроке из куска html - для этого исходный html должен быть ужат до такого же
    # вида, что и итоговый кусок для split - проще всего просто собрать html-string из разобранного document.
    minimized_html_string_data = Floki.raw_html(doc)

    # функция поиска и выковыривания всех библиотек в категории
    libs_parser = fn({name, href})->
      # находим нужный заголовок категории, восстанавливаем его в строчку
      header =
        # в некоторых списках заголовки в h2, в некоторых - в h3. поэтому объединим поиск.
        (Floki.find(doc, "h2") ++ Floki.find(doc, "h3"))
        |> Enum.filter(&Floki.find(&1, "a.anchor[href=\"#{href}\"]")!=[])
        |> List.first
        |> Floki.raw_html

      # ищем и собираем список пар {название_библиотеки, github_url}
      pairs =
        minimized_html_string_data
        |> String.split(header)
        |> List.last
        |> Floki.parse_fragment!
        |> Floki.find("ul")
        |> List.first
        |> Floki.find("li a")
        |> Enum.map(&tuple/1)
        |> Enum.filter(fn{_, link} ->
          String.match?(link, ~r/https:\/\/github.com(\/([a-zA-Z0-9]|-|\.|_)+){2}\/?$/)
        end)

      %{name => pairs}
    end

    # собираем пары {название_категории, якорь}
    hrefs =
      doc
      |> Floki.find("li")
      |> Enum.filter(&Floki.find(&1, "a[href=\"#{anchor}\"]")!=[])
      |> Floki.find("ul a")
      |> Enum.map(&tuple/1)
      |> Enum.uniq

    result = Enum.reduce(hrefs, %{}, fn(href_pair, result) ->
      Map.merge(result, libs_parser.(href_pair))
    end)
    {:ok, result}
  end

  defp tuple(a_href), do: {Floki.text(a_href), a_href |> Floki.attribute("href") |> List.first}
end
