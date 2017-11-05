defmodule PingWeb.HostController do
  use PingWeb, :controller

  alias Ping.Monitor
  alias Ping.Monitor.Host

  def index(conn, _params) do
    hosts = Monitor.list_hosts()
    render(conn, "index.html", hosts: hosts)
  end

  def show(conn, %{"id" => id}) do
    host = Monitor.get_host!(id)
    render(conn, "show.html", host: host)
  end

  def new(conn, _params) do
    changeset = Monitor.change_host(%Host{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"host" => host_params}) do
    case Monitor.create_host(host_params) do
      {:ok, host} ->
        conn
        |> put_flash(:info, "Host created successfully.")
        |> redirect(to: host_path(conn, :show, host))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    host = Monitor.get_host!(id)
    changeset = Monitor.change_host(host)
    render(conn, "edit.html", host: host, changeset: changeset)
  end

  def update(conn, %{"id" => id, "host" => host_params}) do
    host = Monitor.get_host!(id)

    case Monitor.update_host(host, host_params) do
      {:ok, host} ->
        conn
        |> put_flash(:info, "Host updated successfully.")
        |> redirect(to: host_path(conn, :show, host))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", host: host, changeset: changeset)
    end
  end
end
