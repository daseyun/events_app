defmodule EventsAppWeb.UserController do
  use EventsAppWeb, :controller

  alias EventsApp.Users
  alias EventsApp.Users.User
  alias EventsApp.Photos
  alias EventsAppWeb.Plugs

  plug Plugs.RequireUser when action in [:edit, :update]

  plug :fetch_user when action in [
    :show, :photo, :edit, :update, :delete]
  plug :require_owner when action in [
    :edit, :update, :delete]


  def fetch_user(conn, _args) do
    id = conn.params["id"]
    user = Users.get_user!(id)
    assign(conn, :user, user)
  end

  def require_owner(conn, _args) do
    # Precondition: We have these in conn
    current_user = conn.assigns[:current_user]
    user = conn.assigns[:user]

    if user.id == current_user.id do
      conn
    else
      conn
      |> put_flash(:error, "That isn't yours.")
      |> redirect(to: Routes.user_path(conn, :index))
      |> halt()
    end
  end


  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.html", users: users)
  end

  def new(conn, _params) do
    changeset = Users.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    user_photo = user_params["photo"]
    {:ok, hash} = Photos.save_photo(user_photo)

    user_params =
      user_params
      |> Map.put("profile_photo", hash)

    IO.inspect([:userPhoto, user_params])

    case Users.create_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User created successfully. Try logging in above!")
        |> redirect(to: Routes.user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Unable to create account. Possible reasons: invalid form, email in use.")
        # |> render(conn, "new.html", changeset: changeset)
        |> redirect(to: Routes.user_path(conn, :new))
    end
  end

  def show(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    render(conn, "show.html", user: user)
  end

  def edit(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    changeset = Users.change_user(user)
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)
    user_photo = user_params["profile_photo"]

    user_params =
      if user_photo do
        {:ok, hash} = Photos.save_photo(user_photo.filename, user_photo.path)
        Map.put(user_params, "profile_photo", hash)
      else
        user_params
      end

    case Users.update_user(user, user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.page_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    {:ok, _user} = Users.delete_user(user)

    conn
    |> put_flash(:info, "User deleted successfully.")
    |> redirect(to: Routes.user_path(conn, :index))
  end

  def photo(conn, %{"id" => id}) do
    # user = conn.assigns[:user]
    user = Users.get_user!(id)

    if user.profile_photo do
      {:ok, _name, data} = Photos.load_photo(user.profile_photo)

      conn
      |> put_resp_content_type("image/jpeg")
      |> send_resp(200, data)
    else
      conn
      |> send_resp(200, "")
    end
  end

  # def delete(...) do
  #   # FIXME: Remove old image
  # end
end
