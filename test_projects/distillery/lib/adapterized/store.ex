defmodule Storage do
  use MaxoAdapt, default: PostgreSQL, mode: :get_env

  behaviour do
    @doc ~S"Storage type."
    @callback type :: :persistent | :cache
  end

  def persistent?, do: type() == :persistent
end

defmodule PostgreSQL do
  @behaviour Storage

  @impl Storage
  def type, do: :persistent
end

defmodule Redis do
  @behaviour Storage

  @impl Storage
  def type, do: :cache
end
