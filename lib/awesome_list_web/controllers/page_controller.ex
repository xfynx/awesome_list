defmodule AwesomeListWeb.PageController do
  use AwesomeListWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
