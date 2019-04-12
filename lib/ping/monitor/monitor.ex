defmodule Ping.Monitor do
  @moduledoc """
  The Monitor context.
  """

  import Ecto.Query, warn: false
  alias Ping.Repo

  alias Ping.Notifications.Event
  alias Ping.Monitor.{Host, Supervisor}

  @doc """
  Returns the list of hosts.

  ## Examples

      iex> list_hosts()
      [%Host{}, ...]

  """
  def list_hosts do
    from(h in Host, order_by: h.name)
    |> Repo.all()
  end

  @doc """
  Gets a single host.

  Raises `Ecto.NoResultsError` if the Host does not exist.

  ## Examples

      iex> get_host!(123)
      %Host{}

      iex> get_host!(456)
      ** (Ecto.NoResultsError)

  """
  def get_host!(id), do: Repo.get!(Host, id)

  def get_host_by_ip(ip_address), do: Repo.get_by(Host, ip_address: ip_address)

  @doc """
  Creates a host.

  ## Examples

      iex> create_host(%{field: value})
      {:ok, %Host{}}

      iex> create_host(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_host(attrs \\ %{}) do
    %Host{}
    |> Host.changeset(attrs)
    |> Repo.insert()
    |> start_new_host()
  end

  @doc """
  Updates a host.

  ## Examples

      iex> update_host(host, %{field: new_value})
      {:ok, %Host{}}

      iex> update_host(host, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_host(%Host{} = host, attrs) do
    host
    |> Host.changeset(attrs)
    |> Repo.update()
  end

  def update_host(ip_address, attrs) do
    with %Host{} = host <- get_host_by_ip(ip_address) do
      host
      |> Host.update_status_changeset(attrs)
      |> Repo.update()
    else
      _ -> {:error, "Unable to find host with that IP Address"}
    end
  end

  @doc """
  Deletes a Host.

  ## Examples

      iex> delete_host(host)
      {:ok, %Host{}}

      iex> delete_host(host)
      {:error, %Ecto.Changeset{}}

  """
  def delete_host(%Host{} = host) do
    Repo.delete(host)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking host changes.

  ## Examples

      iex> change_host(host)
      %Ecto.Changeset{source: %Host{}}

  """
  def change_host(%Host{} = host) do
    Host.changeset(host, %{})
  end

  def start_monitoring do
    list_hosts()
    |> Enum.each(fn (host) -> Supervisor.start_monitoring_host(host.ip_address, host.status, host.check_frequency) end)
  end

  defp start_new_host ({:ok, %Host{} = host}) do
    Supervisor.start_monitoring_host(host.ip_address, host.status, host.check_frequency)
    {:ok, host}
  end
  defp start_new_host ({:error, %Ecto.Changeset{} = changeset}) do
    {:error, changeset}
  end

  def update_channel do
    html = Phoenix.View.render_to_string(PingWeb.HostView, "dashboard.html", hosts: host_status())
    PingWeb.Endpoint.broadcast("dashboard", "update_html", %{html: html})
  end

  @doc """
  Allows importing multiple hosts via a CSV file.

  host01,8.8.8.8,60000
  host02,8.8.4.4,60000
  host03,127.0.0.1,60000

  Returns a count of hosts added.
  """
  def import_hosts(csv) do
    count =
      csv.path
      |> File.stream!()
      |> CSV.decode(headers: [:name, :ip_address, :check_frequency])
      |> Enum.map(fn (host) -> import_host(host) end)
      |> Enum.count(fn ({k, _v}) -> k == :ok end)

    {:ok, count}
  end

  defp import_host({:ok, host}) do
    with {:ok, new_host} <- create_host(host) do
      {:ok, new_host}
    else
      _ ->
        {:error, "Something went wrong importing host.."}
    end
  end
  defp import_host({:error, message}) do
    IO.puts message
  end

  def host_status do
    # events_query = from e in Event, order_by: [desc: e.inserted_at]

    online_hosts = Repo.all(from h in Host, where: h.status == "online", order_by: h.name)

    offline_hosts =
      Repo.preload(
        Repo.all(
          from h in Host, where: h.status == "offline", order_by: h.name
        ),
        events: from(e in Event,
                      distinct: e.host_id,
                      order_by: [desc: e.inserted_at])
      )
      |> Enum.map(fn host ->

        with [event] <- host.events do
          last_online =
            event.inserted_at
            |> Timex.format!("{relative}", :relative)

          Map.put(host, :last_online, last_online)
        else
          _ -> Map.put(host, :last_online, "unknown")
        end

      end)

    %{online_hosts: online_hosts, offline_hosts: offline_hosts}
  end
end
