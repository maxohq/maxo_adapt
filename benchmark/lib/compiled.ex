defmodule BenchCompiled do
  use MaxoAdapt, default: BenchCompiled.A, mode: :compile, log: false

  behaviour do
    @doc ~S"Some docs"
    @callback some_function :: boolean
  end
end

defmodule BenchCompiled.A do
  @behaviour BenchCompiled

  @impl BenchCompiled
  def some_function, do: false
end

defmodule BenchCompiled.B do
  @behaviour BenchCompiled

  @impl BenchCompiled
  def some_function, do: true
end
