defmodule Ping.Monitor.Registry do
  use GenServer

  # API
  def start_link do
    # We start our registry with a simple name,
    # just so we can reference it in the other functions.
    GenServer.start_link(__MODULE__, nil, name: :registry)
  end

  def whereis_host(host_ip_address) do
    GenServer.call(:registry, {:whereis_host, host_ip_address})
  end
  def register_host(host_ip_address, pid) do
    GenServer.call(:registry, {:register_host, host_ip_address, pid})
  end
  def unregister_host(host_ip_address) do
    GenServer.cast(:registry, {:unregister_host, host_ip_address})
  end

  def send(host_ip_address, message) do
    # If we try to send a message to a process
    # that is not registered, we return a tuple in the format
    # {:badarg, {process_name, error_message}}.
    # Otherwise, we just forward the message to the pid of this
    # room.
    case whereis_host(host_ip_address) do
      :undefined ->
        {:badarg, {host_ip_address, message}}
      pid ->
        Kernel.send(pid, message)
        pid
    end
  end

  # SERVER
  def init(_) do
    # We will use a simple Map to store our processes in
    # the format %{"room name" => pid}
    {:ok, Map.new}
  end

  def handle_call({:whereis_host, host_ip_address}, _from, state) do
    {:reply, Map.get(state, host_ip_address, :undefined), state}
  end

  def handle_call({:register_host, host_ip_address, pid}, _from, state) do
    case Map.get(state, host_ip_address) do
      nil ->
        Process.monitor(pid)
        {:reply, :yes, Map.put(state, host_ip_address, pid)}

      _ ->
        {:reply, :no, state}
    end
  end

  def handle_cast({:unregister_host, host_ip_address}, state) do
    # And unregistering is as simple as deleting an entry
    # from our Map
    {:noreply, Map.delete(state, host_ip_address)}
  end

  def handle_info({:DOWN, _, :process, pid, _}, state) do
    # When a monitored process dies, we will receive a
    # `:DOWN` message that we can use to remove the
    # dead pid from our registry.
    {:noreply, remove_pid(state, pid)}
  end

  def remove_pid(state, pid_to_remove) do
    remove = fn {_key, pid} -> pid  != pid_to_remove end
    Enum.filter(state, remove) |> Enum.into(%{})
  end
end
