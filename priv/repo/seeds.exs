# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     PhotoBlog.Repo.insert!(%PhotoBlog.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
# https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/11-photoblog/notes.md#add-user_id-to-post
alias EventsApp.Repo
alias EventsApp.Users.User
alias EventsApp.Events.Event
alias EventsApp.Invitees.Invitee
alias EventsApp.Photos

defmodule Inject do
  def photo(name) do
    photos = Application.app_dir(:events_app, "priv/photos")
    path = Path.join(photos, name)
    {:ok, hash} = Photos.save_photo(name, path)
    hash
  end
end


default_photo = Inject.photo("default.png")

alice = Repo.insert!(%User{name: "alice", email: "alice@mail.com", profile_photo: default_photo})
bob = Repo.insert!(%User{name: "bob", email: "bob@mail.com", profile_photo: default_photo})

p1 = Repo.insert!(%Event{
  event_name: "Alice's event",
  date: ~N[2000-01-01 23:00:07],
  description: "test description [Alice]",
  user_id: alice.id,
  # invitees: %{:yes => ["a@mail.com", "b@mail.com"], :maybe => [], :no => ["ac@mail.com"], :no_response => []}
  # invitees: %{"yes" => [], "maybe" => [], "no" => [], "no_response" => []}
})

i1 = %Invitee{
  user_id: alice.id,
  event_id: p1.id
}
Repo.insert!(i1)


# p2 = %Event{
#   event_name: "Bob's event",
#   date: ~N[2000-02-01 23:00:07],
#   description: "test description [BOb]",
#   user_id: bob.id,
#   invitees: %{:yes => [], :maybe => [], :no => [], :no_response => []}

# }
# Repo.insert!(p2)
