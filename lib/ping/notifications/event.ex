defmodule Ping.Notifications.Event do
  use Ecto.Schema
  import Ecto.Changeset
  alias Ping.Notifications.Event

  schema "events" do
    field :status, :string
    belongs_to :host, Ping.Monitor.Host

    timestamps()
  end

  @doc false
  def changeset(%Event{} = event, attrs) do
    event
    |> cast(attrs, [:host_id, :status])
    |> validate_required([:host_id, :status])
  end
end
