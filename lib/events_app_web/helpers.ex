# https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/13-access-rules/notes.md#branch-05-access

defmodule EventsAppWeb.Helpers do
  alias EventsApp.Users.User

  def have_current_user?(conn) do
    conn.assigns[:current_user] != nil
  end

  def current_user_id(conn) do
    user = conn.assigns[:current_user]
    user && user.id
  end

  def current_user_is?(conn, %User{} = user) do
    current_user_is?(conn, user.id)
  end

  def current_user_is?(conn, user_id) do
    current_user_id(conn) == user_id
  end

  def user_is_invited?(conn, event) do
    user = conn.assigns[:current_user]

    IO.inspect([:xxx, event])
    cond do
      user == nil ->
        false

      user.id == event.user_id -> true

      true ->
        user_invited =
          Enum.any?(event.invitees, fn x ->
            x.user_id == user.id
          end)

        if user_invited do
          true
        else
          false
        end
    end
  end
end
