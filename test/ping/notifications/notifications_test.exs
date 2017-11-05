defmodule Ping.NotificationsTest do
  use Ping.DataCase

  alias Ping.Monitor
  alias Ping.Notifications

  describe "hosts" do
    alias Ping.Notifications.Event

    @valid_host_attrs %{ip_address: "8.8.8.8", name: "some name", check_frequency: 60000}
    @invalid_event_attrs {:online, "8.8.8.8"}

    def host_fixture(attrs \\ %{}) do
      {:ok, host} =
        attrs
        |> Enum.into(@valid_host_attrs)
        |> Monitor.create_host()

      host
    end

    test "create_event/2 with valid data creates online event" do
      host = host_fixture()

      assert {:ok, %Event{} = event} = Notifications.create_event({:online, host.ip_address})
      assert event.host_id == host.id
      assert event.status == "online"
    end

    test "create_event/2 with valid data creates offline event" do
      host = host_fixture()

      assert {:ok, %Event{} = event} = Notifications.create_event({:offline, host.ip_address})
      assert event.host_id == host.id
      assert event.status == "offline"
    end

    test "create_event/2 with invalid host returns error" do
      assert {:error, _} = Notifications.create_event(@invalid_event_attrs)
    end
  end
end
