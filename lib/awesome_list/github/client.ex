defmodule AwesomeList.Github.Client do
  @moduledoc """
  Клиент для запросов в Github
  """
  use Tesla

  require Logger

  @api_endpoint "https://api.github.com/"
  @endpoint "https://github.com/"

  def endpoint, do: @endpoint
  def api_endpoint, do: @api_endpoint

  @config Application.get_env(:awesome_list, AwesomeList.Github.Client)

  plug Tesla.Middleware.Headers, [{"User-Agent", "awesome agent"}]
  # Без учётки количество запросов в час ограничено 60, с учёткой - 5000 на месяц.
  # Этого всё равно крайне мало - в районе 166 запросов в сутки.
  # Поэтому, если уж планируем поддерживать N списков, нужно либо использовать список прокси, либо автоматизировать
  # регистрацию аккаунтов в github и заводить новые пары client/secret в пул.
  plug Tesla.Middleware.BasicAuth, username: @config[:client_id], password: @config[:client_secret]
  plug Tesla.Middleware.JSON
  plug Tesla.Middleware.FollowRedirects
  plug AwesomeList.Github.RateLimitsGuard

  @doc """
  Чтение html-страницы README.md из мастер-ветки.

  В действительности, с html-страницей проще работать, чем с markdown-кодом по
  api - она удобней структурирована и парсится.
  Поэтому вытягивать из репозитория будем непосредственно саму страницу.
  """
  def readme(repo_path) do
    Logger.info("request repo readme: " <> repo_path)
    "#{@endpoint}#{repo_path}/blob/master/README.md"
    |> get()
    |> response()
  end

  @doc """
  Получить метаинформацию о репозитории.

  - на вход полный url репозитория (не api), например: "https://github.com/user/repo"
  - результат - map вида:
  ```
  %{
   description: "Dalmatiner flow processing library.", # <--- описание
   last_commit_at: ~N[2017-09-26 22:44:20],            # <--- последний пуш в репозитории. Важно! Учитываются все ветки
   stars_count: 11                                     # <--- количество звёздочек, очевидно :)
  }
  ```
  """
  # Гипотетически, запросы НЕ по api не имеют особых ограничений на количество и плотность, и можно от этого отталкиваться.
  def repo_meta(repo_url) do
    Logger.info("request repo meta: " <> repo_url)
    url = to_api_repo_url(repo_url)
    response =
      url
      |> get()
      |> response()

    case response do
      {:ok, data} ->
        {:ok, %{
          last_commit_at: NaiveDateTime.from_iso8601!(data["pushed_at"]),
          description: data["description"],
          stars_count: data["stargazers_count"]
        }}

      {:error, :not_found} ->
        nil

      {:error, :rate_limit_exceeded} ->
        repo_meta(repo_url)

      any ->
        any
    end
  end

  defp to_api_repo_url(repo_url), do: String.replace(repo_url, @endpoint, @api_endpoint <> "repos/")

  defp response({:ok, %Tesla.Env{status: 200, body: body}}), do: {:ok, body}
  defp response({:ok, %Tesla.Env{status: 403, body: %{"message" => "API rate limit exceeded" <> _}}}) do
    {:error, :rate_limit_exceeded}
  end
  defp response({:ok, %Tesla.Env{status: 404, body: _}}) do
    {:error, :not_found}
  end
  defp response({:ok, %Tesla.Env{status: status, body: %{"message" => message}, url: url}}) do
    {:error, "Error fetching #{url}: [#{status}] #{message}"}
  end
  defp response({:error, reason}), do: {:error, to_string(reason)}
end