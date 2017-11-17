defmodule PingWeb.DashboardChannel do
  @moduledoc """
  Channel for updating Dashboard
  """
  use Phoenix.Channel

  def join("dashboard", _message, socket) do
    {:ok, socket}
  end
end
