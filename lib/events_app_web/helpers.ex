defmodule EventsAppWeb.Helpers do
  def have_current_user?(conn) do
    conn.assigns[:current_user] != nil
  end

  def current_user_id(conn) do
    user = conn.assigns[:current_user]
    user && user.id
  end

end
