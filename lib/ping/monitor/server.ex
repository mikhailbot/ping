defmodule Ping.Monitor.Server do
  use GenServer

  # API

  def start_link(host_ip_address) do
    GenServer.start_link(__MODULE__, [], host: via_tuple(host_ip_address))
  end

  defp via_tuple(host_ip_address) do
    {:via, Ping.Monitor.Registry, {:registry, host_ip_address}}
  end

  def add_message(host_ip_address, message) do
    GenServer.cast(via_tuple(host_ip_address), {:add_message, message})
  end

  def get_messages(host_ip_address) do
    GenServer.call(via_tuple(host_ip_address), :get_messages)
  end

  # SERVER

  def init(messages) do
    {:ok, messages}
  end

  def handle_cast({:add_message, new_message}, messages) do
    {:noreply, [new_message | messages]}
  end

  def handle_call(:get_messages, _from, messages) do
    {:reply, messages, messages}
  end
end
