# Show what your package is capable of!
defmodule Storage do
  use MaxoAdapt, validate: true, mode: :compile, default: PostgreSQL

  behaviour do
    @doc ~S"Store an item"
    @callback store(item :: term) :: :ok | {:error, atom}

    @doc ~S"Delete an item"
    @callback delete(term) :: :ok | {:error, atom}
  end
end

defmodule PostgreSQL do
  @behaviour Storage

  @impl Storage
  def store(item)
  def store(item), do: {:ok, {item, :store, :psql}}

  @impl Storage
  def delete(item)
  def delete(item), do: {:ok, {item, :delete, :psql}}
end

defmodule Redis do
  @behaviour Storage

  @impl Storage
  def store(item)
  def store(_), do: :ok

  @impl Storage
  def delete
  def delete, do: :ok
end

defmodule Sqlite do
  @behaviour Storage

  @impl Storage
  def store(item)
  def store(item), do: {:ok, {item, :store, :sqlite}}

  @impl Storage
  def delete(item)
  def delete(item), do: {:ok, {item, :delete, :sqlite}}
end

# re-configure with default impl
Storage.configure(PostgreSQL)
# this fails
Storage.configure(Redis)
# this works
Storage.configure(Sqlite)
# Enjoy using it! 💜
