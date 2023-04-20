defmodule MaxoAdapt.Impl.GetEnv do
  @moduledoc false

  @doc false
  @spec generate(term, MaxoAdapt.Utility.behaviour(), MaxoAdapt.Utility.config()) :: term
  def generate(code, callbacks, config) do
    %{
      app: app,
      key: key,
      log: log,
      error: error,
      default: default,
      validate: validate
    } = config

    err =
      if error == :raise do
        quote do: raise("#{__MODULE__} not configured.")
      else
        quote do: {:error, unquote(error)}
      end

    quote do
      unquote(code)
      ast = unquote(generate_implementation(callbacks, err))
      MaxoAdapt.Log.inspect_ast(ast, "GetEnv.generate")

      quote do
        unquote(ast)
      end

      @doc false
      @spec __maxo_adapt__ :: module | nil
      def __maxo_adapt__, do: Application.get_env(unquote(app), unquote(key), unquote(default))

      @doc ~S"""
      Configure a new adapter implementation.

      ## Example

      ```elixir
      iex> configure(Fake)
      :ok
      ```
      """
      @spec configure(module) :: :ok
      def configure(adapter) do
        with false <- __maxo_adapt__() == adapter && :ok,
             :ok <-
               unquote(
                 MaxoAdapt.Utility.generate_validation(
                   validate,
                   callbacks,
                   Macro.var(:adapter, __MODULE__)
                 )
               ) do
          Application.put_env(unquote(app), unquote(key), adapter, persistent: true)
          unquote(MaxoAdapt.Utility.generate_logger(log, Macro.var(:adapter, __MODULE__)))
          :ok
        end
      end
    end
  end

  @spec generate_implementation(MaxoAdapt.Utility.behaviour(), term) :: term
  defp generate_implementation(callbacks, error) do
    Enum.map(callbacks, fn {key, %{spec: spec, doc: doc, args: a}} ->
      vars = Enum.map(a, &Macro.var(&1, nil))

      quote do
        unquote(doc)
        unquote(spec)
        def unquote(key)(unquote_splicing(vars))

        def unquote(key)(unquote_splicing(vars)) do
          if adapter = __maxo_adapt__(),
            do: adapter.unquote(key)(unquote_splicing(vars)),
            else: unquote(error)
        end
      end
    end)
  end
end
