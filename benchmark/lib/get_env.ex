defmodule BenchGetEnv do
  use MaxoAdapt, default: BenchGetEnv.A, mode: :get_env, log: false, validate: false

  behaviour do
    @doc ~S"Some docs"
    @callback some_function :: boolean
  end
end

defmodule BenchGetEnv.A do
  @behaviour BenchGetEnv

  @impl BenchGetEnv
  def some_function, do: false
end

defmodule BenchGetEnv.B do
  @behaviour BenchGetEnv

  @impl BenchGetEnv
  def some_function, do: true
end
