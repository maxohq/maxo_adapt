defmodule MaxoAdapt.Impl.Compile do
  @moduledoc false

  @doc false
  @spec generate(term, MaxoAdapt.Utility.behaviour(), MaxoAdapt.Utility.config()) :: term
  def generate(code, callbacks, config)

  def generate(code, callbacks, config) do
    %{default: default, error: error, log: log, random: random, validate: validate} = config
    simple_callbacks = Enum.map(callbacks, fn {k, %{args: args}} -> {k, Enum.count(args)} end)

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

    MaxoAdapt.Log.inspect_ast(code, "Compile.generate: CODE")

    inner_ast = generate_compiled_delegates(callbacks, Module.concat(MaxoAdapt, config.adapter))
    MaxoAdapt.Log.inspect_ast(inner_ast, "Compile.generate: INNER_AST")

    quote do
      unquote(code)
      unquote(inner_ast)

      @doc false
      @spec __maxo_adapt__ :: module | nil
      def __maxo_adapt__, do: unquote(nil)

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
        Code.put_compiler_option(:ignore_module_conflict, true)

        with false <- __maxo_adapt__() == adapter && :ok,
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
          Code.put_compiler_option(:ignore_module_conflict, false)
          :ok
        end
      end
    end
  end

  @doc false
  @spec recompile_module(module, [{atom, non_neg_integer()}], module) :: :ok
  def recompile_module(module, callbacks, target) do
    mod = Module.concat(MaxoAdapt, module)
    :code.purge(mod)
    :code.delete(mod)

    ast =
      quote do
        defmodule unquote(mod) do
          @moduledoc false
          @doc false
          @spec __maxo_adapt__ :: module | nil
          def __maxo_adapt__, do: unquote(target)

          unquote(regenerate_redirect(callbacks, target))
        end
      end

    MaxoAdapt.Log.inspect_ast(ast, "Compile.recompile_module - AST")
    Code.compile_quoted(ast)
    :ok
  end

  @spec generate_compiled_delegates(MaxoAdapt.Utility.behaviour(), module) :: term
  defp generate_compiled_delegates(callbacks, target) do
    Enum.map(callbacks, fn {key, %{spec: spec, doc: doc, args: args}} ->
      vars = Enum.map(args, &Macro.var(&1, nil))

      quote do
        unquote(doc)
        unquote(spec)
        def unquote(key)(unquote_splicing(vars))
        defdelegate unquote(key)(unquote_splicing(vars)), to: unquote(target)
      end
    end)
  end

  @spec generate_stubs(MaxoAdapt.Utility.behaviour(), term) :: term
  defp generate_stubs(callbacks, result) do
    Enum.map(callbacks, fn {key, %{spec: spec, doc: docs, args: args}} ->
      quote do
        unquote(docs)
        unquote(spec)
        def unquote(key)(unquote_splicing(Enum.map(args, &Macro.var(&1, nil))))

        def unquote(key)(unquote_splicing(Enum.map(args, &Macro.var(:"_#{&1}", nil)))),
          do: unquote(result)
      end
    end)
  end

  @spec regenerate_redirect([{atom, non_neg_integer()}], module) :: term
  defp regenerate_redirect(callbacks, target) do
    Enum.map(callbacks, fn {key, arity} ->
      vars = if arity > 0, do: Enum.map(1..arity, &Macro.var(:"arg#{&1}", nil)), else: []

      quote do
        defdelegate unquote(key)(unquote_splicing(vars)), to: unquote(target)
      end
    end)
  end
end
