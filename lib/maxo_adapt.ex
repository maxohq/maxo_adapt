defmodule MaxoAdapt do
  @moduledoc false
  alias MaxoAdapt.Config

  @default_app :maxo_adapt
  @default_log :debug
  @default_random true
  @default_validate true

  @typedoc ~S"""

  `:app` and `:key`.
  """
  @type option ::
          {:app, atom}
          | {:key, atom}
          | {:default, module}
          | {:error, :raise | atom}
          | {:log, false | :debug | :info | :notice}
          | {:mode, :compile | :get_compiled | :get_env | :get_dict}
          | {:random, boolean}
          | {:validate, boolean}

  @doc false
  @spec __using__(opts :: [option]) :: term
  defmacro __using__(opts \\ []) do
    Module.put_attribute(__CALLER__.module, :adapter_opts, parse_config(__CALLER__.module, opts))

    quote do
      require unquote(__MODULE__)
      import unquote(__MODULE__), only: [behaviour: 1]
    end
  end

  @doc ~S"""
  Define the adapter behaviour through callbacks.
  A `@doc` tag can be set for each `@callback`.

  Each callback is useable

  ## Example

  ```elixir
  behaviour do
    @doc ~S\"""
    Get session from storage.
    \"""
    @callback get(token :: binary) :: {:ok, Session.t | nil} | {:error, atom}
  end
  ```
  """
  @spec behaviour(callbacks :: [{:do, term}]) :: term
  defmacro behaviour(do: block), do: setup(__CALLER__.module, block)

  @spec setup(module, term) :: term
  defp setup(module, block) do
    {type, opts} = Module.get_attribute(module, :adapter_opts)
    {code, callbacks} = __MODULE__.Utility.analyze(block)
    type.generate(code, callbacks, opts)
  end

  @spec parse_config(module, Keyword.t()) :: {module, term}
  defp parse_config(module, opts) do
    adapter =
      module
      |> Atom.to_string()
      |> String.replace_leading("Elixir.", "")
      |> String.split(".")
      |> Enum.map(&Macro.underscore/1)

    {default, opts} = Keyword.pop(opts, :default)
    {app, opts} = Keyword.pop(opts, :app, @default_app)
    {key, opts} = Keyword.pop(opts, :key, :"#{Enum.join(adapter, "_")}")
    {error, opts} = Keyword.pop(opts, :error, :"#{List.last(adapter)}_not_configured")
    {log, opts} = Keyword.pop(opts, :log, @default_log)
    {random, opts} = Keyword.pop(opts, :random, @default_random)
    {validate, opts} = Keyword.pop(opts, :validate, @default_validate)

    config = %{
      adapter: module,
      app: app,
      key: key,
      default: default,
      error: error,
      log: log,
      random: random,
      validate: validate
    }

    case Keyword.get(opts, :mode, Config.default_mode()) do
      :compile ->
        {__MODULE__.Impl.Compile, config}

      :get_env ->
        {__MODULE__.Impl.GetEnv, config}

      :get_dict ->
        {__MODULE__.Impl.GetDict, config}

      :get_compiled ->
        {__MODULE__.Impl.GetCompiled, config}

      m ->
        raise CompileError,
          description:
            "Invalid MaxoAdapt Mode: #{inspect(m)}. Only `:compile`, `:get_compiled`, `:get_env` and `:get_dict` are supported."
    end
  end
end
