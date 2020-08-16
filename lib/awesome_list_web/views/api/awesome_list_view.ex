defmodule AwesomeListWeb.Api.AwesomeListView do
  use AwesomeListWeb, :view

  def render("show.json", %{data: data}) do
    %{
      code: 200,
      data: data
    }
  end
end
