defmodule Ping.ServerTest do
  use Ping.DataCase

  describe "new server" do
    alias Ping.Monitor.Server

    setup do
      {:ok, server_pid} = Server.start_link("127.0.0.1", "initial", 10)

      on_exit fn ->
        Process.exit server_pid, "End of test"
      end

      {:ok, server: server_pid}
    end

    test ":get_state returns hosts initial state" do
      assert {:ok, state} = Server.get_state("127.0.0.1")
      assert state.ip_address == "127.0.0.1"
      assert state.status == "initial"
      assert state.check_frequency == 10
    end

    test ":work returns hosts new state", %{server: pid} do
      assert :ok = Process.send(pid, :work, [])

      assert {:ok, state} = Server.get_state("127.0.0.1")
      assert state.ip_address == "127.0.0.1"
      assert state.status == "online"
      assert state.latency != 0
    end
  end

  describe "status changing server" do
    alias Ping.Monitor.Server

    setup do
      {:ok, server_pid} = Server.start_link("127.0.0.1", "offline", 10)

      on_exit fn ->
        Process.exit server_pid, "End of test"
      end

      {:ok, server: server_pid}
    end

    test ":work updates online counter", %{server: pid} do
      assert :ok = Process.send(pid, :work, [])

      assert {:ok, state} = Server.get_state("127.0.0.1")
      assert state.ip_address == "127.0.0.1"
      assert state.status == "offline"
      assert state.online_counter != 0
    end
  end

  # Would like to also test the offline situation
  # but that would involve waiting for the ping to timeout
end
