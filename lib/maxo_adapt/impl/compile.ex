defmodule MaxoAdapt.Impl.Compile do
  @moduledoc false

  @doc false
  @spec generate(term, MaxoAdapt.Utility.behavior(), MaxoAdapt.Utility.config()) :: term
  def generate(code, callbacks, config)

  def generate(code, callbacks, config) do
    %{default: default, error: error, log: log, random: random, validate: validate} = config
    simple_callbacks = Enum.map(callbacks, fn {k, %{args: a}} -> {k, Enum.count(a)} end)

    stubs =
      if default do
        generate_compiled_delegates(callbacks, default)
      else
        generate_stubs(callbacks, MaxoAdapt.Utility.generate_error(error, random))
      end

    ast =
      quote do
        defmodule unquote(Module.concat(MaxoAdapt, config.adapter)) do
          @moduledoc false
          unquote(stubs)
        end
      end

    MaxoAdapt.Log.inspect_ast(ast, "Compile.generate: AST")
    Code.compile_quoted(ast)

    quote do
      unquote(code)
      unquote(generate_compiled_delegates(callbacks, Module.concat(MaxoAdapt, config.adapter)))

      @doc false
      @spec __adapter__ :: module | nil
      def __adapter__, do: unquote(nil)

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
        with false <- __adapter__() == adapter && :ok,
             :ok <-
               unquote(
                 MaxoAdapt.Utility.generate_validation(
                   validate,
                   callbacks,
                   Macro.var(:adapter, __MODULE__)
                 )
               ),
             :ok <-
               unquote(__MODULE__).recompile_module(
                 __MODULE__,
                 unquote(simple_callbacks),
                 adapter
               ) do
          unquote(MaxoAdapt.Utility.generate_logger(log, Macro.var(:adapter, __MODULE__)))
          :ok
        end
      end
    end
  end

  @doc false
  @spec recompile_module(module, [{atom, non_neg_integer()}], module) :: :ok
  def recompile_module(module, callbacks, target) do
    with {mod, data, file} <- :code.get_object_code(module),
         {:ok, {^mod, chunks}} <- :beam_lib.chunks(data, [:abstract_code]),
         {_, code} <- Keyword.get(chunks, :abstract_code) do
      :code.purge(module)
      :code.delete(module)

      updated_code = replace_compiled_delegates(code, callbacks, target)

      with {:ok, ^mod, bin} <- :compile.forms(updated_code) do
        :code.load_binary(mod, file, bin)
        :ok
      end
    else
      _ ->
        mod = Module.concat(MaxoAdapt, module)
        :code.purge(mod)
        :code.delete(mod)

        ast =
          quote do
            defmodule unquote(mod) do
              @moduledoc false
              unquote(regenerate_redirect(callbacks, target))
            end
          end

        MaxoAdapt.Log.inspect(ast, label: "Compile.recompile_module - AST")
        MaxoAdapt.Log.puts(Macro.to_string(ast))

        Code.compile_quoted(ast)
        :ok
    end
  end

  @spec replace_compiled_delegates(term, [{atom, non_neg_integer()}], module) :: term
  defp replace_compiled_delegates(ast, callbacks, target) do
    Enum.map(ast, fn
      {:function, l, :__adapter__, 0, [{:clause, l, [], [], [{:atom, 0, _}]}]} ->
        {:function, l, :__adapter__, 0, [{:clause, l, [], [], [{:atom, 0, target}]}]}

      a = {:function, _, name, arity, [data]} ->
        if {name, arity} in callbacks do
          {:clause, l, vars, [],
           [{:call, l, {:remote, l, {:atom, l, _target}, {:atom, l, function}}, vars}]} = data

          {:function, l, name, arity,
           [
             {:clause, l, vars, [],
              [{:call, l, {:remote, l, {:atom, 0, target}, {:atom, l, function}}, vars}]}
           ]}
        else
          a
        end

      a ->
        a
    end)
  end

  @spec generate_compiled_delegates(MaxoAdapt.Utility.behavior(), module) :: term
  defp generate_compiled_delegates(callbacks, target) do
    Enum.reduce(callbacks, nil, fn {key, %{spec: spec, doc: doc, args: args}}, acc ->
      vars = Enum.map(args, &Macro.var(&1, nil))

      quote do
        unquote(acc)

        unquote(doc)
        unquote(spec)
        def unquote(key)(unquote_splicing(vars))
        defdelegate unquote(key)(unquote_splicing(vars)), to: unquote(target)
      end
    end)
  end

  @spec generate_stubs(MaxoAdapt.Utility.behavior(), term) :: term
  defp generate_stubs(callbacks, result) do
    Enum.reduce(callbacks, nil, fn {key, %{spec: spec, doc: docs, args: a}}, acc ->
      quote do
        unquote(acc)

        unquote(docs)
        unquote(spec)
        def unquote(key)(unquote_splicing(Enum.map(a, &Macro.var(&1, nil))))

        def unquote(key)(unquote_splicing(Enum.map(a, &Macro.var(:"_#{&1}", nil)))),
          do: unquote(result)
      end
    end)
  end

  @spec regenerate_redirect([{atom, non_neg_integer()}], module) :: term
  defp regenerate_redirect(callbacks, target) do
    Enum.reduce(callbacks, nil, fn {key, arity}, acc ->
      vars = if arity > 0, do: Enum.map(1..arity, &Macro.var(:"arg#{&1}", nil)), else: []

      quote do
        unquote(acc)
        defdelegate unquote(key)(unquote_splicing(vars)), to: unquote(target)
      end
    end)
  end
end
