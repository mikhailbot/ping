defmodule Ping.MonitorTest do
  use Ping.DataCase

  alias Ping.Monitor

  describe "hosts" do
    alias Ping.Monitor.Host

    @valid_attrs %{ip_address: "8.8.8.8", name: "some name", check_frequency: 60000}
    @update_attrs %{ip_address: "8.8.4.4", name: "some updated name", check_frequency: 120000}
    @update_status_attrs %{status: "online", latency: 20}
    @invalid_attrs %{ip_address: nil, name: nil, check_frequency: nil}
    @invalid_ip_attrs %{ip_address: "something wrong", name: "some name", check_frequency: 60000}
    @invalid_frequency_attrs %{ip_address: "8.8.8.8", name: "some name", check_frequency: 100}

    def host_fixture(attrs \\ %{}) do
      {:ok, host} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Monitor.create_host()

      host
    end

    test "list_hosts/0 returns all hosts" do
      host = host_fixture()
      assert Monitor.list_hosts() == [host]
    end

    test "get_host!/1 returns the host with given id" do
      host = host_fixture()
      assert Monitor.get_host!(host.id) == host
    end

    test "get_host_by_ip/1 returns the host with the given ip address" do
      host = host_fixture()
      assert Monitor.get_host_by_ip(host.ip_address) == host
    end

    test "create_host/1 with valid data creates a host" do
      assert {:ok, %Host{} = host} = Monitor.create_host(@valid_attrs)
      assert host.ip_address == "8.8.8.8"
      assert host.name == "some name"
      assert host.check_frequency == 60000
    end

    test "create_host/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Monitor.create_host(@invalid_attrs)
    end

    test "update_host/2 with valid data updates the host" do
      host = host_fixture()
      assert {:ok, host} = Monitor.update_host(host, @update_attrs)
      assert %Host{} = host
      assert host.ip_address == "8.8.4.4"
      assert host.name == "some updated name"
      assert host.check_frequency == 120000
    end

    test "update_host/2 with invalid data returns error changeset" do
      host = host_fixture()
      assert {:error, %Ecto.Changeset{}} = Monitor.update_host(host, @invalid_attrs)
      assert host == Monitor.get_host!(host.id)
    end

    test "update_host/2 with status data updates the host" do
      host = host_fixture()
      assert {:ok, host} = Monitor.update_host(host.ip_address, @update_status_attrs)
      assert %Host{} = host
      assert host.ip_address == "8.8.8.8"
      assert host.status == "online"
      assert host.latency == 20
    end

    test "delete_host/1 deletes the host" do
      host = host_fixture()
      assert {:ok, %Host{}} = Monitor.delete_host(host)
      assert_raise Ecto.NoResultsError, fn -> Monitor.get_host!(host.id) end
    end

    test "change_host/1 returns a host changeset" do
      host = host_fixture()
      assert %Ecto.Changeset{} = Monitor.change_host(host)
    end

    test "create_host/1 with invalid ip address returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Monitor.create_host(@invalid_ip_attrs)
    end

    test "create_host/1 with invalid check frequency returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Monitor.create_host(@invalid_frequency_attrs)
    end

    test "import_hosts/1 with valid csv creates hosts" do
      assert {:ok, count} = Monitor.import_hosts(File.stream!("test/fixtures/valid_hosts.csv"))
      assert count == 2
    end

    test "import_hosts/1 with invalid csv creates only valid hosts" do
      assert {:ok, count} = Monitor.import_hosts(File.stream!("test/fixtures/invalid_hosts.csv"))
      assert count == 2
    end
  end
end
