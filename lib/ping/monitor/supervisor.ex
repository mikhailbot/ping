defmodule Ping.Monitor.Supervisor do
  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: :monitor_supervisor)
  end

  def start_monitoring_host(ip_address, status) do
    Supervisor.start_child(:monitor_supervisor, [ip_address, status])
  end

  def init(_) do
    children = [
      worker(Ping.Monitor.Server, [])
    ]

    supervise(children, strategy: :simple_one_for_one)
  end
end
