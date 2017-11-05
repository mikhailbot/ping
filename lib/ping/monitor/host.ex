defmodule Ping.Monitor.Host do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ping.Monitor.Host
  alias Ping.Monitor.IPv4

  schema "hosts" do
    field :ip_address, IPv4
    field :latency, :integer
    field :name, :string
    field :status, :string, default: "initial"
    field :check_frequency, :integer # ms

    has_many :events, Ping.Notifications.Event

    timestamps()
  end

  @doc false
  def changeset(%Host{} = host, attrs) do
    host
    |> cast(attrs, [:name, :ip_address, :check_frequency])
    |> validate_required([:name, :ip_address, :check_frequency])
    |> validate_number(:check_frequency, greater_than_or_equal_to: 60000)
    |> unique_constraint(:ip_address)
  end
end
