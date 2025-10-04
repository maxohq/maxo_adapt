# MaxoAdapt Cheatsheet

## Overview
Fast, safe adapter pattern implementation for Elixir with compile-time safety and runtime flexibility.

**Fork of:** `adapter` by IanLuites
**Current Version:** 0.1.11
**Elixir:** ~> 1.14

---

## Quick Start

```elixir
# Add to mix.exs
{:maxo_adapt, "~> 0.1"}
```

```elixir
# Define adapter
defmodule SessionRepo do
  use MaxoAdapt

  behaviour do
    @doc "Lookup session by token"
    @callback get(token :: binary) :: {:ok, Session.t | nil} | {:error, atom}
  end

  def get!(token) do
    case get(token) do
      {:ok, result} -> result
      {:error, reason} -> raise "SessionRepo: #{reason}"
    end
  end
end

# Implement
defmodule SessionRepo.PostgreSQL do
  @behaviour SessionRepo
  @impl SessionRepo
  def get(token), do: {:ok, {token, :psql}}
end

# Configure
SessionRepo.configure(SessionRepo.PostgreSQL)
```

---

## Core Concepts

### Adapter Definition
```elixir
defmodule MyRepo do
  use MaxoAdapt, mode: :compile, default: PostgreSQL, validate: true

  behaviour do
    @doc "Description"
    @callback function_name(arg :: type) :: return_type
  end
end
```

### Implementation
```elixir
defmodule MyRepo.PostgreSQL do
  @behaviour MyRepo

  @impl MyRepo
  def function_name(arg), do: # implementation
end
```

### Configuration
```elixir
MyRepo.configure(MyRepo.PostgreSQL)  # Runtime switching
```

---

## Modes

### `:compile` (Default)
**Best balance of flexibility + performance**
- Recompiles module on configuration change
- Fast as hardcoded delegates
- Runtime switching supported

### `:get_compiled`
**Fastest, no runtime changes**
- Links adapter at compile-time via `Application.compile_env/3`
- Hardcoded performance
- Set in `config.exs`, cannot change at runtime

### `:get_env`
**Most flexible, slowest**
- Looks up adapter via `Application.get_env/3` on each call
- Instant reconfiguration via `Application.put_env/3`
- No recompilation needed

### `:get_dict`
**For testing**
- Uses process dictionary via `MaxoAdapt.ProcDict.get_with_ancestors/2`
- Isolated adapter per test process
- Works with async tests and subprocesses

---

## Configuration Options

```elixir
use MaxoAdapt,
  mode: :compile,                    # :compile | :get_compiled | :get_env | :get_dict
  default: PostgreSQL,               # default implementation module
  app: :my_app,                      # app name for config lookups (default: :maxo_adapt)
  key: :my_repo,                     # config key (default: snake_case module name)
  error: :repo_not_configured,       # error atom or :raise
  log: :info,                        # :debug | :info | :notice | false
  random: true,                      # trick dialyzer with Enum.random wrapper
  validate: true                     # validate implementation at configure-time
```

### Global Defaults
```elixir
# config/config.exs
config :maxo_adapt,
  default_mode: :compile,           # sets default mode for all adapters
  debug: false                      # verbose debug output
```

---

## Key Features

✅ **Fast** - as fast as hardcoded `defdelegate`
✅ **Easy** - define behaviour, rest is automatic
✅ **Safe** - validates implementation matches behaviour
✅ **Clean** - clear separation of concerns
✅ **Flexible** - runtime adapter switching
✅ **Docs** - copies `@doc` from callbacks to stubs
✅ **Specs** - generates matching `@spec` for each stub
✅ **IDE** - intellisense/autocomplete support
✅ **Releases** - compatible with `distillery` and `mix release`

---

## Common Patterns

### Multiple Callbacks
```elixir
behaviour do
  @callback get(id :: binary) :: {:ok, term} | {:error, atom}
  @callback store(item :: term) :: :ok | {:error, atom}
  @callback delete(id :: binary) :: :ok | {:error, atom}
end
```

### Callbacks with `when`
```elixir
behaviour do
  @callback process(data :: t) :: result when t: term, result: term
end
```

### Multiple Functions with Same Name
```elixir
behaviour do
  @callback delete() :: :ok
  @callback delete(id :: binary) :: :ok
end
```

---

## Debugging

### Enable Debug Mode
```elixir
# config/config.exs
config :maxo_adapt, debug: true
```

Output shows:
- Generated AST for modules
- Recompiled code on reconfiguration
- Detailed compilation steps

### Check Current Adapter
```elixir
MyRepo.__maxo_adapt__()  # Returns current implementation module
```

---

## Testing

### With `:get_dict` mode
```elixir
# test/test_helper.exs
# Set default_mode globally or per-adapter

# In tests
defmodule MyRepoTest do
  use ExUnit.Case, async: true  # async safe!

  setup do
    MyRepo.configure(MyRepo.Mock)
    :ok
  end

  test "uses mock adapter" do
    assert {:ok, _} = MyRepo.get("token")
  end
end
```

---

## Architecture

```
┌──────────────────┐
│   Your Module    │  Defines behaviour via callbacks
│                  │
│  use MaxoAdapt   │
│  behaviour do    │
│    @callback...  │
└────────┬─────────┘
         │
         ▼
┌──────────────────────────┐
│  MaxoAdapt.YourModule    │  Generated helper module
│                          │
│  - __maxo_adapt__()      │  Returns current adapter
│  - delegates/stubs       │  One per callback
└────────┬─────────────────┘
         │
         ▼
┌──────────────────────────┐
│  YourModule.PostgreSQL   │  Implementation
│  YourModule.Redis        │
│  YourModule.Mock         │
└──────────────────────────┘
```

---

## Error Handling

### Default Behavior
```elixir
# Returns error tuple if not configured
{:error, :module_name_not_configured}
```

### Raise on Error
```elixir
use MaxoAdapt, error: :raise

# Raises if not configured
# ** (RuntimeError) "Elixir.MyRepo not configured."
```

### Custom Error Atom
```elixir
use MaxoAdapt, error: :my_custom_error

# Returns
{:error, :my_custom_error}
```

---

## Project Structure

```
lib/
├── maxo_adapt.ex                 # Main macro entry point
├── maxo_adapt/
│   ├── config.ex                # Global config helpers
│   ├── utility.ex               # AST analysis & validation
│   ├── log.ex                   # Debug logging
│   ├── proc_dict.ex             # Process dictionary support
│   └── impl/
│       ├── compile.ex           # :compile mode
│       ├── get_compiled.ex      # :get_compiled mode
│       ├── get_env.ex           # :get_env mode
│       └── get_dict.ex          # :get_dict mode
```

---

## Links

- **Hex:** https://hex.pm/packages/maxo_adapt
- **Docs:** https://hexdocs.pm/maxo_adapt
- **GitHub:** https://github.com/maxohq/maxo_adapt
- **Guides:**
  - [Intro](guides/intro.md)
  - [Configuration](guides/configuration.md)
  - [Debugging](guides/debugging.md)

---

## License
MIT
