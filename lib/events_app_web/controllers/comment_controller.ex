defmodule EventsAppWeb.CommentController do
  use EventsAppWeb, :controller

  alias EventsApp.Comments
  alias EventsApp.Comments.Comment
  alias EventsApp.Events
  alias EventsApp.Users

  def index(conn, _params) do
    comments = Comments.list_comments()
    render(conn, "index.html", comments: comments)
  end

  def new(conn, _params) do
    changeset = Comments.change_comment(%Comment{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"comment" => comment_params}) do


    comment_params = comment_params
    |> Map.put("user_id", current_user_id(conn))
    {event_id, _} = Integer.parse(comment_params["event_id"])
    user_id = comment_params["user_id"]

    # IO.inspect([:COMMENT, comment_params])

    user_comment = Comments.get_comment(user_id, event_id)
    IO.inspect([:COMMENT, user_comment, event_id, user_id])

    if user_comment != nil do
      # update
      update(conn, %{"id" => user_comment.id, "comment" => comment_params})

    else
      # DEBUG: user_comment is nil. why?

      user = Users.get_user!(user_id)
      event = Events.get_event!(event_id)
      all_comments = Comments.list_comments()
      IO.inspect([:COMMENT_IS_NIL, user, event])
      IO.inspect([:ALLCOMMENTS, all_comments])

      # END DEBUG

      event = Events.get_event!(event_id)

      case Comments.create_comment(comment_params) do
        {:ok, _} ->
          conn
          |> put_flash(:info, "Comment created successfully.")
          |> redirect(to: Routes.event_path(conn, :show, event))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html", changeset: changeset)
      end

    end



    # case Comments.create_comment(comment_params) do
    #   {:ok, comment} ->
    #     conn
    #     |> put_flash(:info, "Comment created successfully.")
    #     |> redirect(to: Routes.comment_path(conn, :show, comment))

    #   {:error, %Ecto.Changeset{} = changeset} ->
    #     render(conn, "new.html", changeset: changeset)
    # end
  end

  def show(conn, %{"id" => id}) do
    comment = Comments.get_comment!(id)
    render(conn, "show.html", comment: comment)
  end

  def edit(conn, %{"id" => id}) do
    comment = Comments.get_comment!(id)
    changeset = Comments.change_comment(comment)
    render(conn, "edit.html", comment: comment, changeset: changeset)
  end

  def update(conn, %{"id" => id, "comment" => comment_params}) do
    comment = Comments.get_comment!(id)
    event = Events.get_event!(comment.event_id)

    case Comments.update_comment(comment, comment_params) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Comment updated successfully.")
        |> redirect(to: Routes.event_path(conn, :show, event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", comment: comment, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    comment = Comments.get_comment!(id)
    event = Events.get_event!(comment.event_id)
    {:ok, _comment} = Comments.delete_comment(comment)

    conn
    |> put_flash(:info, "Comment deleted successfully.")
    |> redirect(to: Routes.event_path(conn, :show, event))
  end
end
