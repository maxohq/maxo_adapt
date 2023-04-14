## Guide

First define the module that can use different adapters.
The behaviour of the adapter is defined with `@callback` like normal,
but this time wrapped in a `behavio[u]r` macro.

```elixir
defmodule SessionRepo do
  use MaxoAdapt

  behaviour do
    @doc ~S"""
    Lookup a sessions based on token.
    """
    @callback get(token :: binary) :: {:ok, Session.t | nil} | {:error, atom}
  end

  @spec get!(binary) :: Session.t | nil | no_return
  def get!(token) do
    case get(token) do
      {:ok, result} -> result
      {:error, reason} -> raise "SessionRepo: #{reason}"
    end
  end
end
```

## How does it work?

The functionality is quite simple.

Inside the `behaviour` block each `@callback` is tracked
and documentation and spec recorded.

After the `behaviour` block each recorded callback will generate a stub.
Each stub will be given the recorded documentation and spec.
This allows functions in the module to call the functions
from the defined behaviour.

On configuration either the application config updated to reflect the change
or in `:compile` mode the module is purged and recompiled with the new adapter.
