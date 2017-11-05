defmodule Ping.Repo.Migrations.CreateEvents do
  use Ecto.Migration

  def change do
    create table(:events) do
      add :host_id, references(:hosts)
      add :status, :string

      timestamps()
    end
  end
end
