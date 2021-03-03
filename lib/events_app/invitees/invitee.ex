defmodule EventsApp.Invitees.Invitee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "invitees" do
    field :event_status, :string
    # field :event_id, :id
    belongs_to :event, EventsApp.Events.Event
    belongs_to :user, EventsApp.Users.User

    # field :user_id, :id

    timestamps()
  end

  @doc false
  def changeset(invitee, attrs) do
    invitee
    |> cast(attrs, [:event_status, :event_id, :user_id])
    |> validate_required([:event_status, :event_id, :user_id])
  end
end
