defmodule EventsApp.Repo.Migrations.CreateInvitees do
  use Ecto.Migration

  def change do
    create table(:invitees) do
      add :event_status, :string, null: false, default: "no_response"
      add :event_id, references(:events, on_delete: :nothing), null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create index(:invitees, [:event_id])
    # create index(:invitees, [:user_id])

    create unique_index(:invitees, [:user_id])
  end
end
