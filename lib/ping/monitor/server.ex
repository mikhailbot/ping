defmodule Ping.Monitor.Server do
  use GenServer

  # API

  def start_link(host_ip_address, host_status) do
    GenServer.start_link(__MODULE__, %{host_ip_address: host_ip_address, host_status: host_status}, name: via_tuple(host_ip_address))
  end

  defp via_tuple(host_ip_address) do
    {:via, :gproc, {:n, :l, {:host_monitor, host_ip_address}}}
  end

  def get_state(host_ip_address) do
    GenServer.call(via_tuple(host_ip_address), :get_state)
  end

  # SERVER

  def init(initial_state) do
    state = %{
      ip_address: initial_state.host_ip_address,
      current_status: initial_state.host_status,
      previous_stuatus: initial_state.host_status,
      latency: 0,
      status_changes: 0
    }

    {:ok, state}
  end

  def handle_call(:get_state, _from, state) do
    {:reply, state, state}
  end
end
