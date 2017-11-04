defmodule PingWeb.PageController do
  use PingWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
