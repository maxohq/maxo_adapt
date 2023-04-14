## Configuration

Adapters come with the following configuration options:

- `:default` (_none_),
  a default implementation to link to at first compile.

- `:error` (`:module_name_not_configured`),
  an atom that is returned in an error tuple when the adapter has not been configured.
  Can be set to `:raise` to raise instead of returning an error tuple.

- `:log` (`:info`),
  the log level of the configuration message.
  The following levels are allowed: `:debug`, `:info`, and `:notice`.
  To disable logging of configuration set `log: false`.

- `:mode` (`:compile`),
  determines the implementation type of the adapter pattern.
  The following modes are supported:

  - `:compile`, the stubs are replaced each time by recompiling the module.
    This gives hardcoded performance
    while still allowing changes of adapter at runtime.

  - `:compile_env`, the macro hardcodes the adapter at compile time.
    This works by using `Application.compile_env`.
    (or `Application.get_env` below _Elixir 1.11_.)
    It mirrors the standard adapter pattern using module attributes
    and defdelegates.
    It is fast, but requires the adapter to be set at compile
    and can no longer be changed at runtime like startup.

  - `:get_env`, the macro generates an `Application.get_env` pattern.
    Looking up the set adapter for each call, allowing for easy runtime switching.
    This is slower in use than a `:compile` and `:compile_env`,
    but the fastest to re-configure
    and simpler than `:compile` when it comes to the underlying mechanic.

- `:random` (`true`),
  wraps the default implementation in an `Enum.random([...])` to trick `dialyzer`.
  Dialyzer might error out, because it detects the hardcoded [error] values
  before the adapter is configured.
  To avoid this causing issues the hardcoded value is wrapped in random.
  This forces dialyzer to respect the spec instead of the implementation.

- `:validate` (`true`),
  whether to perform configuration validation.
  This will verify a given implementation actually implements the complete behaviour.
  It will error out and refuse to configure if there are functions missing
  or have a wrong arity.
  Setting this to `false` will skip validation, making configuration slightly faster
  and allow setting incomplete implementations.

When using `:compile_env` or `:get_env` the implementation will default to using
`:maxo_adapt` as app and the module name as key when doing configuration lookups.

To define a custom config location pass `app: :my_app, key: :my_repo`.
