defmodule Ping.Monitor.Host do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ping.Monitor.Host
  alias Ping.Monitor.IPv4

  schema "hosts" do
    field :ip_address, IPv4
    field :latency, :integer
    field :name, :string
    field :status, :string, default: "unknown"

    timestamps()
  end

  @doc false
  def changeset(%Host{} = host, attrs) do
    host
    |> cast(attrs, [:name, :ip_address])
    |> validate_required([:name, :ip_address])
    |> unique_constraint(:ip_address)
  end
end
