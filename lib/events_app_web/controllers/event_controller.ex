defmodule EventsAppWeb.EventController do
  use EventsAppWeb, :controller

  alias EventsApp.Events
  alias EventsApp.Events.Event
  alias EventsAppWeb.Plugs
  alias EventsApp.Invitees

  # https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/13-access-rules/notes.md#branch-05-access
  plug Plugs.RequireUser when action in [:new, :edit, :create, :update]

  plug :fetch_event
       when action in [
              :show,
              :edit,
              :update,
              :delete
            ]

  plug :require_owner
       when action in [
              :edit,
              :update,
              :delete
            ]

  plug :require_invited
       when action in [
              :show,
              :edit,
              :update,
              :delete
            ]

  def fetch_event(conn, _args) do
    id = conn.params["id"]
    event = Events.get_event!(id)
    assign(conn, :event, event)
  end

  def require_owner(conn, _args) do
    # Precondition: We have these in conn
    user = conn.assigns[:current_user]
    event = conn.assigns[:event]

    # IO.inspect([:REQUIRE_OWNER, event])
    if user.id == event.user_id do
      conn
    else
      conn
      |> put_flash(:error, "That isn't yours.")
      |> redirect(to: Routes.event_path(conn, :index))
      |> halt()
    end
  end

  def require_invited(conn, _args) do
    # Precondition: We have these in conn
    user = conn.assigns[:current_user]

    event =
      conn.assigns[:event]
      |> Events.load_invitees()

    IO.inspect([:INVITED, event.invitees])
    user_loggedin? = user != nil

    cond do

      user_loggedin? == false ->
        conn
        |> put_flash(:error, "Please Log In or Register.")
        |> redirect(to: Routes.user_path(conn, :new, params: event.id))
        |> halt()

      user.id == event.user_id -> conn

      user_loggedin? == true ->
        user_invited =
          Enum.any?(event.invitees, fn x ->
            x.user.id == user.id
          end)

        if user_invited do
          conn
        else
          conn
          |> put_flash(:error, "You do not have access. ")
          |> redirect(to: Routes.page_path(conn, :index))
          |> halt()
        end
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

    event_params =
      event_params
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
    event =
      conn.assigns[:event]
      |> Events.load_comments()
      |> Events.load_invitees()

    user = conn.assigns[:current_user]

    comm = %EventsApp.Comments.Comment{
      event_id: event.id,
      user_id: current_user_id(conn)
    }

    new_comment = EventsApp.Comments.change_comment(comm)

    inv = %EventsApp.Invitees.Invitee{
      event_id: event.id,
      event_status: "no_response"
    }

    new_invitee = EventsApp.Invitees.change_invitee(inv)
    current_user_invite = Invitees.get_invitee(user.id, event.id)

    current_invite_change = if current_user_invite do
      Invitees.change_invitee(current_user_invite)
    else
      Invitees.change_invitee(inv)
    end

    inv_status_numbers = countEventStatusNumbers(event.invitees)

    # event = Events.get_event!(id)
    # |> Events.load_invitees
    render(conn, "show.html",
      event: event,
      new_comment: new_comment,
      new_invitee: new_invitee,
      current_user_invite: current_user_invite,
      current_invite_change: current_invite_change,
      inv_status_numbers: inv_status_numbers
    )
  end

  def edit(conn, %{"id" => id}) do
    event =
      Events.get_event!(id)
      |> Events.load_invitees()

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

  def countEventStatusNumbers(invitees) do
    r = Enum.reduce(invitees, [0, 0, 0, 0], fn inv, acc ->
      [y, m, n, nr] = acc

      cond do
        inv.event_status == "yes" ->
          [y + 1, m, n, nr]

        inv.event_status == "maybe" ->
          [y, m + 1, n, nr]

        inv.event_status == "no" ->
          [y, m, n + 1, nr]

        true ->
          [y, m, n, nr + 1]
      end
    end)
    [y, m, n, nr] = r
    %{"yes" => y, "maybe" => m, "no" => n, "no_response" => nr}
  end
end
