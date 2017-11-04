defmodule Ping.Monitor.Server do
  use GenServer

  # API

  def start_link(host_ip_address, host_status) do
    GenServer.start_link(__MODULE__, [host_ip_address, host_status], name: via_tuple(host_ip_address))
  end

  defp via_tuple(host_ip_address) do
    {:via, :gproc, {:n, :l, {:host_monitor, host_ip_address}}}
  end

  def add_message(host_ip_address, message) do
    GenServer.cast(via_tuple(host_ip_address), {:add_message, message})
  end

  def get_state(host_ip_address) do
    GenServer.call(via_tuple(host_ip_address), :get_state)
  end

  # SERVER

  def init(host_ip_address) do
    IO.puts "INIT"
    # state = %{ ip_address: host_ip_address, current_status: host_status, previous_stuatus: host_status, latency: 0, status_changes: 0}
    {:ok, host_ip_address}
  end

  def handle_cast({:add_message, new_message}, state) do
    {:noreply, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end
