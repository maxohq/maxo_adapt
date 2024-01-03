defmodule MaxoAdapt.Impl.GetCompiled do
  @moduledoc false

  @doc false
  @spec generate(term, MaxoAdapt.Utility.behaviour(), MaxoAdapt.Utility.config()) :: term
  def generate(code, callbacks, config) do
    %{app: app, default: default, error: error, key: key, random: random} = config

    err = MaxoAdapt.Utility.generate_error(error, random)

    quote location: :keep do
      @adapter Application.compile_env(unquote(app), unquote(key), unquote(default))

      unquote(code)

      if @adapter do
        unquote(generate_implementation(callbacks))
      else
        require Logger

        Logger.warning(fn ->
          """
          [MaxoAdapt] #{inspect(__MODULE__)} is not configured.
              Mode `:get_compiled` adapters can not be changed at runtime.
              Use `mode: :compile` or `mode: :get_env` to allow runtime reconfiguration.
              Tested with `app: :#{unquote(app)}, :key: :#{unquote(key)}`

              Configure in `config.exs` with:
              `config :#{unquote(app)}, #{unquote(key)}: DefaultAdapterModule`
          """
        end)

        unquote(generate_errors(callbacks, err))
      end

      @doc false
      @spec __maxo_adapt__ :: module | nil
      def __maxo_adapt__, do: @adapter

      @doc ~S"""
      Configure a new adapter implementation.

      ## Example

      ```elixir
      iex> configure(Fake)
      :ok
      ```
      """
      @spec configure(module) :: :ok
      def configure(adapter)

      def configure(_) do
        raise "An adapter configured with `:get_compiled` can't be changed at runtime."
      end
    end
  end

  @spec generate_errors(MaxoAdapt.Utility.behaviour(), term) :: term
  defp generate_errors(callbacks, error) do
    Enum.map(callbacks, fn {key, %{spec: spec, doc: doc, args: args}} ->
      vars = Enum.map(args, &Macro.var(&1, nil))
      u_vars = Enum.map(args, &Macro.var(:"_#{&1}", nil))

      quote do
        unquote(doc)
        unquote(spec)
        def unquote(key)(unquote_splicing(vars))
        def unquote(key)(unquote_splicing(u_vars)), do: unquote(error)
      end
    end)
  end

  @spec generate_implementation(MaxoAdapt.Utility.behaviour()) :: term
  defp generate_implementation(callbacks) do
    Enum.map(callbacks, fn {key, %{spec: spec, doc: doc, args: args}} ->
      vars = Enum.map(args, &Macro.var(&1, nil))

      quote do
        unquote(doc)
        unquote(spec)

        def unquote(key)(unquote_splicing(vars))

        def unquote(key)(unquote_splicing(vars)) do
          @adapter.unquote(key)(unquote_splicing(vars))
        end
      end
    end)
  end
end
