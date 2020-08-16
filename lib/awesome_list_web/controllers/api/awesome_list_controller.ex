defmodule AwesomeListWeb.Api.AwesomeListController do
  use AwesomeListWeb, :controller

  alias AwesomeList.Repo.Presenter

  def languages(conn, _params) do
    render(conn, "show.json", data: Presenter.languages())
  end

  def categories_with_libs(conn, params) do
    render(conn, "show.json", data: Presenter.categories_with_libs(to_i(params["id"]), to_i(params["min_stars"])))
  end

  defp to_i(val) do
    case Integer.parse(val) do
      {val, _rest} -> val
      :error -> 0
    end
  end
end
