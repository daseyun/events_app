defmodule EventsAppWeb.EventController do
  use EventsAppWeb, :controller

  alias EventsApp.Events
  alias EventsApp.Events.Event
  alias EventsAppWeb.Plugs

  # https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/13-access-rules/notes.md#branch-05-access
  plug Plugs.RequireUser when action in [:new, :edit, :create, :update]

  plug :fetch_event when action in [
    :show, :edit, :update, :delete]
  plug :require_owner when action in [
    :edit, :update, :delete]

  def fetch_event(conn, _args) do
    id = conn.params["id"]
    event = Events.get_event!(id)
    assign(conn, :event, event)
  end

  def require_owner(conn, _args) do
    # Precondition: We have these in conn
    user = conn.assigns[:current_user]
    event = conn.assigns[:event]

    if user.id == event.user_id do
      conn
    else
      conn
      |> put_flash(:error, "That isn't yours.")
      |> redirect(to: Routes.event_path(conn, :index))
      |> halt()
    end
  end


  def index(conn, _params) do
    events = Events.list_events()
    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    changeset = Events.change_event(%Event{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"event" => event_params}) do
    IO.inspect([:event_params, event_params])
    event_params = event_params
    |> Map.put("user_id", conn.assigns[:current_user].id)

    case Events.create_event(event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event created successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    # post = Posts.load_comments(conn.assigns[:post])
    # event = Events.load_comments(conn.assigns[:event])
    event = conn.assigns[:event]
    |> Events.load_comments
    |> Events.load_invitees

    comm = %EventsApp.Comments.Comment{
      event_id: event.id,
      user_id: current_user_id(conn)
    }
    new_comment = EventsApp.Comments.change_comment(comm)


    # event = Events.get_event!(id)
    # |> Events.load_invitees
    render(conn, "show.html", event: event, new_comment: new_comment)
  end

  def edit(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    |> Events.load_invitees
    IO.inspect([:aa, event])
    changeset = Events.change_event(event)
    render(conn, "edit.html", event: event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "event" => event_params}) do
    event = Events.get_event!(id)

    case Events.update_event(event, event_params) do
      {:ok, event} ->
        conn
        |> put_flash(:info, "Event updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", event: event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = Events.get_event!(id)
    {:ok, _event} = Events.delete_event(event)

    conn
    |> put_flash(:info, "Event deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :index))
  end
end
