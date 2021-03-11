defmodule EventsApp.Events.Event do
  use Ecto.Schema
  import Ecto.Changeset

  schema "events" do
    field :date, :naive_datetime
    field :description, :string
    field :event_name, :string
    belongs_to :user, EventsApp.Users.User
    # field :invitees, :map
    has_many :invitees, EventsApp.Invitees.Invitee
    has_many :comments, EventsApp.Comments.Comment

    # embeds_one :invitees, StandardUrls, on_replace: :update do
    #   field(:yes, {:array,:integer))
    #   field(:maybe, :array)
    #   field(:no, :array)
    #   field(:no_response, :array)
    # end

    timestamps()
  end

  @doc false
  def changeset(event, attrs) do
    event
    |> cast(attrs, [:event_name, :date, :description, :user_id])
    |> validate_required([:event_name, :date, :description, :user_id])
  end
end
