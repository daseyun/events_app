defmodule EventsApp.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  schema "users" do
    field :email, :string
    field :name, :string
    field :profile_photo, :string
    has_many :events, EventsApp.Events.Event
    has_many :invitees, EventsApp.Invitees.Invitee
    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :email, :profile_photo])
    |> validate_required([:name, :email])
    |> unique_constraint(:email)

  end
end
