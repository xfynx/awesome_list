defmodule AwesomeListWeb.Router do
  use AwesomeListWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", AwesomeListWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  scope "/api", AwesomeListWeb.Api do
    pipe_through :api

    get "/languages", AwesomeListController, :languages
    get "/categories_with_libs", AwesomeListController, :categories_with_libs
  end
end
