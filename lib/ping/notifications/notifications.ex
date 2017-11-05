defmodule Ping.Notifications do
  import Ecto.Query, warn: false
  alias Ping.Repo
  alias Ping.Monitor
  alias Ping.Monitor.Host
  alias Ping.Notifications.Event

  def create_event({:online, ip_address}) do
    with %Host{} = host <- Monitor.get_host_by_ip(ip_address) do
      %Event{}
      |> Event.changeset(%{host_id: host.id, status: "online"})
      |> Repo.insert()
    else
      _ -> {:error, "Unable to find host with that IP Address"}
    end
  end

  def create_event({:offline, ip_address}) do
    with %Host{} = host <- Monitor.get_host_by_ip(ip_address) do
      %Event{}
      |> Event.changeset(%{host_id: host.id, status: "offline"})
      |> Repo.insert()
    else
      _ -> {:error, "Unable to find host with that IP Address"}
    end
  end
end
