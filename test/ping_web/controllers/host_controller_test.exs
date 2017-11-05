defmodule PingWeb.HostControllerTest do
  @moduledoc false

  use PingWeb.ConnCase

  alias Ping.Monitor

  @create_attrs %{ip_address: "8.8.8.8", name: "some name", check_frequency: 60000}
  @update_attrs %{ip_address: "8.8.4.4", name: "some updated name", check_frequency: 80000}
  @invalid_attrs %{ip_address: 1, name: 2, check_frequency: 3}

  def fixture(:host) do
    {:ok, host} = Monitor.create_host(@create_attrs)
    host
  end

  describe "index" do
    test "lists all hosts", %{conn: conn} do
      conn = get conn, host_path(conn, :index)
      assert html_response(conn, 200) =~ "Ping"
    end
  end

  describe "new host" do
    test "renders form", %{conn: conn} do
      conn = get conn, host_path(conn, :new)
      assert html_response(conn, 200) =~ "New Host"
    end
  end

  describe "create host" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, host_path(conn, :create), host: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == host_path(conn, :show, id)

      conn = get conn, host_path(conn, :show, id)
      assert html_response(conn, 200) =~ "some name"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, host_path(conn, :create), host: @invalid_attrs
      assert html_response(conn, 200) =~ "New Host"
    end
  end

  describe "edit host" do
    setup [:create_host]

    test "renders form for editing chosen host", %{conn: conn, host: host} do
      conn = get conn, host_path(conn, :edit, host)
      assert html_response(conn, 200) =~ "Edit some name"
    end
  end

  describe "update host" do
    setup [:create_host]

    test "redirects when data is valid", %{conn: conn, host: host} do
      conn = put conn, host_path(conn, :update, host), host: @update_attrs
      assert redirected_to(conn) == host_path(conn, :show, host)

      conn = get conn, host_path(conn, :show, host)
      assert html_response(conn, 200) =~ "8.8.4.4"
    end

    test "renders errors when data is invalid", %{conn: conn, host: host} do
      conn = put conn, host_path(conn, :update, host), host: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit some name"
    end
  end

  defp create_host(_) do
    host = fixture(:host)
    {:ok, host: host}
  end
end
