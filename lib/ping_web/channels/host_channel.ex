defmodule PingWeb.HostChannel do
  @moduledoc """
  Channel for updating Host latency
  """
  use Phoenix.Channel

  def join("hosts", _message, socket) do
    {:ok, socket}
  end
end
