# code attribution:
#  https://github.com/NatTuck/scratch-2021-01/blob/master/notes-4550/12-uploads/notes.md#branch-04-photo-uploads
defmodule EventsApp.Photos do



  # grab the default picture for users that don't upload.
  def load_default do
    photo = Application.app_dir(:events_app, "priv/photos")
    path = Path.join(photo, "noProfile.png")
    {:ok, hash} = save_photo("noProfile.png", path)
    hash
  end
  # wrapper
  # check if photo was inserted.
  # if so, save.
  # else do nothing and return ok.
  def save_photo(photo_arg) do

    # [
    #   :save_p,
    #   %Plug.Upload{
    #     content_type: "image/jpeg",
    #     filename: "xxxx.jpg",
    #     path: "/var/folders/nn/b0shlqz526ncclq968dy29600000gn/T//plug-1615/multipart-1615258739-71035508000923-3"
    #   }
    # ]
    if photo_arg == nil do
      {:ok, nil}
    else
      save_photo(photo_arg.filename, photo_arg.path)
    end
  end

  def save_photo(name, path) do
    data = File.read!(path)
    hash = sha256(data)
    meta = read_meta(hash)
    save_photo(name, data, hash, meta)
  end

  def save_photo(name, data, hash, nil) do
    File.mkdir_p!(base_path(hash))
    meta = %{
      name: name,
      refs: 0,
    }
    save_photo(name, data, hash, meta)
  end

  # Problem: Data race
  #  - Two users upload the same photo
  #  - Both processes read the metadata with
  #    the old refcount
  #  - Both processes add one
  #  - Both processes write (refs + 1)
  #  - We wanted (refs + 2)
  # Potential fix:
  #  - Put metadata in a table in the DB
  def save_photo(name, data, hash, meta) do
    meta = Map.update!(meta, :refs, &(&1 + 1))
    File.write!(meta_path(hash), Jason.encode!(meta))
    File.write!(data_path(hash), data)
    {:ok, hash}
  end

  def load_photo(hash) do
    data = File.read!(data_path(hash))
    meta = File.read!(meta_path(hash))
    |> Jason.decode!
    {:ok, Map.get(meta, :name), data}
  end

  # TODO: drop_photo

  def read_meta(hash) do
    with {:ok, data} <- File.read(meta_path(hash)),
         {:ok, meta} <- Jason.decode(data, keys: :atoms)
    do
      meta
    else
      _ -> nil
    end
  end

  def base_path(hash) do
    Path.expand("~/.local/data/photo_blog")
    |> Path.join("#{Mix.env}")
    |> Path.join(String.slice(hash, 0, 2))
    |> Path.join(String.slice(hash, 2, 30))
  end

  def meta_path(hash) do
    Path.join(base_path(hash), "meta.json")
  end

  def data_path(hash) do
    Path.join(base_path(hash), "photo.jpg")
  end

  def sha256(data) do
    :crypto.hash(:sha256, data)
    |> Base.encode16(case: :lower)
  end
end
