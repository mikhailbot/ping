defmodule PingWeb.Router do
  use PingWeb, :router

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

  scope "/", PingWeb do
    pipe_through :browser # Use the default browser stack

    get "/", HostController, :index
    get "/dashboard", HostController, :dashboard

    resources "/hosts", HostController
  end

  # Other scopes may use custom stacks.
  # scope "/api", PingWeb do
  #   pipe_through :api
  # end
end
