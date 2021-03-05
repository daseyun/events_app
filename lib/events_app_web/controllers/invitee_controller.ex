defmodule EventsAppWeb.InviteeController do
  use EventsAppWeb, :controller

  alias EventsApp.Invitees
  alias EventsApp.Invitees.Invitee
  alias EventsApp.Events

  def index(conn, _params) do
    invitees = Invitees.list_invitees()
    render(conn, "index.html", invitees: invitees)
  end

  # def new(conn, params) do
  #   IO.inspect([:new, params])
  #   changeset = Invitees.change_invitee(%Invitee{})
  #   render(conn, "new.html", changeset: changeset)
  # end

  def new(conn, %{"param" => event_id}) do
    {event_id, _ } = Integer.parse(event_id)

    changeset = Invitees.change_invitee(%Invitee{event_id: event_id, event_status: "no_response"})
    # event = Events.get_event!(event_id)

    # new_invitee = [%Invitee{
    #   event_id: event_id,
    #   # event: event,
    #   event_status: "no_response",
    #   # id: 1,
    #   # inserted_at: ~N[2021-03-03 07:02:42],
    #   # updated_at: ~N[2021-03-03 07:02:42],
    #   # user: #Ecto.Association.NotLoaded<association :user is not loaded>,
    #   # user_id: 1
    # }]

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"invitee" => invitee_params}) do
    IO.inspect([:create, invitee_params])
    # manipulate invitee_params
    case Invitees.create_invitee(invitee_params) do
      {:ok, invitee} ->
        conn
        |> put_flash(:info, "Invitee created successfully.")
        |> redirect(to: Routes.invitee_path(conn, :show, invitee))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    invitee = Invitees.get_invitee!(id)
    render(conn, "show.html", invitee: invitee)
  end

  def edit(conn, %{"id" => id}) do


    invitee = Invitees.get_invitee!(id)
    changeset = Invitees.change_invitee(invitee)
    IO.inspect([:edit, invitee, changeset])
    render(conn, "edit.html", invitee: invitee, changeset: changeset)
  end

  def update(conn, %{"id" => id, "invitee" => invitee_params}) do
    invitee = Invitees.get_invitee!(id)

    case Invitees.update_invitee(invitee, invitee_params) do
      {:ok, invitee} ->
        conn
        |> put_flash(:info, "Invitee updated successfully.")
        |> redirect(to: Routes.invitee_path(conn, :show, invitee))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", invitee: invitee, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    invitee = Invitees.get_invitee!(id)
    {:ok, _invitee} = Invitees.delete_invitee(invitee)

    conn
    |> put_flash(:info, "Invitee deleted successfully.")
    |> redirect(to: Routes.invitee_path(conn, :index))
  end
end
