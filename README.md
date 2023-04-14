# MaxoAdapt

[![Hex.pm](https://img.shields.io/hexpm/v/maxo_adapt.svg)](https://hex.pm/packages/maxo_adapt)
[![Docs](https://img.shields.io/badge/hexdocs-docs-8e7ce6.svg)](https://hexdocs.pm/maxo_adapt)
[![CI](https://github.com/maxohq/maxo_adapt/actions/workflows/ci.yml/badge.svg)](https://github.com/maxohq/maxo_adapt/actions/workflows/ci.yml)

`MaxoAdapt` is a fork from https://github.com/IanLuites/adapter with updates / fixes.

---

Fast adapters with clear syntax and build-in safety.

## Why use MaxoAdapt?

- Fast _(as fast as hardcoded `defdelegate`s)_
- Easy _(define a behaviour and it takes care of everything else)_
- Safe _(will error if the implementation does not match the behaviour)_
- Clean _(clearly separated marked behaviour/delegate versus functions)_
- Flexible _(change implementation/adapter at runtime)_

In addition to these basic qualities it is:

- Compatible and tested with releases (`distillery`, `mix release`)
- Documentation compatible _(each stub copies the documentation of the `@callback`)_
- Spec / Dialyzer _(each stub has a spec matching the `@callback`)_
- IDE (intelligent code completion / intellisense) compatible [stubs]

## Usage

```elixir
def deps do
  [
    {:maxo_adapt, "~> 0.1"}
  ]
end
```

```elixir
defmodule SessionRepo do
  use MaxoAdapt

  # Define the adapter behaviour
  behaviour do
    @doc ~S"""
    Lookup a sessions based on token.
    """
    @callback get(token :: binary) :: {:ok, Session.t | nil} | {:error, atom}
  end

  # Add module functions outside the behaviour definition
  # These can use the behaviour's callbacks like they exist as functions.
  @spec get!(binary) :: Session.t | nil | no_return
  def get!(token) do
    case get(token) do
      {:ok, result} -> result
      {:error, reason} -> raise "SessionRepo: #{reason}"
    end
  end
end

# PostgreSQL implementation
defmodule SessionRepo.PostgreSQL do
  @behaviour SessionRepo

  @impl SessionRepo
  def get(token), do: ...
end

# Redis implementation
defmodule SessionRepo.Redis do
  @behaviour SessionRepo

  @impl SessionRepo
  def get(token), do: ...
end

# Now configure
SessionRepo.configure(SessionRepo.PostgreSQL)

# Runtime switching possible
SessionRepo.configure(SessionRepo.Redis)
```

## Guides

- [Intro](https://github.com/maxohq/maxo_adapt/tree/main/guides/intro.md)
- [Configuration](https://github.com/maxohq/maxo_adapt/tree/main/guides/configuration.md)
- [Debugging](https://github.com/maxohq/maxo_adapt/tree/main/guides/debugging.md)

The docs can be found at <https://hexdocs.pm/maxo_adapt>.
