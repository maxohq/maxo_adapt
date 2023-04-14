## Debugging

To have more verbose output and see the recompiled code, set the debug flag to true:

```elixir
config :maxo_adapt, debug: true
```

Possible output:

```elixir
Compile.recompile_module - AST: {:defmodule, [context: MaxoAdapt.Impl.Compile, imports: [{2, Kernel}]],
 [
   MaxoAdapt.MaxoAdaptTest.Storage,
   [
     do: {:__block__, [],
      [
        {:@, [context: MaxoAdapt.Impl.Compile, imports: [{1, Kernel}]],
         [{:moduledoc, [context: MaxoAdapt.Impl.Compile], [false]}]},
        {:@, [context: MaxoAdapt.Impl.Compile, imports: [{1, Kernel}]],
         [{:doc, [context: MaxoAdapt.Impl.Compile], [false]}]},
        {:@, [context: MaxoAdapt.Impl.Compile, imports: [{1, Kernel}]],
         [
           {:spec, [context: MaxoAdapt.Impl.Compile],
            [
              {:"::", [],
               [
                 {:__maxo_adapt__, [], MaxoAdapt.Impl.Compile},
                 {:|, [], [{:module, [], MaxoAdapt.Impl.Compile}, nil]}
               ]}
            ]}
         ]},
        {:def,
         [context: MaxoAdapt.Impl.Compile, imports: [{1, Kernel}, {2, Kernel}]],
         [
           {:__maxo_adapt__, [context: MaxoAdapt.Impl.Compile],
            MaxoAdapt.Impl.Compile},
           [do: MaxoAdaptTest.PostgreSQL]
         ]},
        {:__block__, [],
         [
           {:__block__, [],
            [
              nil,
              {:defdelegate,
               [context: MaxoAdapt.Impl.Compile, imports: [{2, Kernel}]],
               [
                 {:delete, [], [{:arg1, [], nil}]},
                 [to: MaxoAdaptTest.PostgreSQL]
               ]}
            ]},
           {:defdelegate,
            [context: MaxoAdapt.Impl.Compile, imports: [{2, Kernel}]],
            [{:store, [], [{:arg1, [], nil}]}, [to: MaxoAdaptTest.PostgreSQL]]}
         ]}
      ]}
   ]
 ]}

MaxoAdaptTest [lib/maxo_adapt_test.exs]
defmodule MaxoAdapt.MaxoAdaptTest.Storage do
  @moduledoc false
  @doc false
  @spec __maxo_adapt__ :: module | nil
  def __maxo_adapt__ do
    MaxoAdaptTest.PostgreSQL
  end

  (
    (
      nil
      defdelegate delete(arg1), to: MaxoAdaptTest.PostgreSQL
    )

    defdelegate store(arg1), to: MaxoAdaptTest.PostgreSQL
  )
end
```
