# https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/11-photoblog/notes.md#branch-03-add-users
defmodule EventsAppWeb.SessionController do
  use EventsAppWeb, :controller

  def create(conn, %{"email" => email}) do
    # TODO: test this
    user = EventsApp.Users.get_user_by_email(email)
    if user do
      if user.name == "no_name" do
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Please complete your profile and revisit the provided link!")
        |> redirect(to: Routes.user_path(conn, :edit, user))
      else
        conn
        |> put_session(:user_id, user.id)
        |> put_flash(:info, "Welcome back #{user.name}")
        |> redirect(to: Routes.page_path(conn, :index))
      end

    else
      conn
      |> put_flash(:error, "Login failed.")
      |> redirect(to: Routes.page_path(conn, :index))
    end
  end

  def delete(conn, _params) do
    conn
    |> delete_session(:user_id)
    |> put_flash(:info, "Logged out.")
    |> redirect(to: Routes.page_path(conn, :index))
  end
end
