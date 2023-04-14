defmodule MaxoAdapt.Log do
  @active Application.compile_env(:maxo_adapt, :debug, false)

  if @active do
    def inspect_ast(ast, location) do
      MaxoAdapt.Log.inspect(ast, label: location)
      IO.puts(Macro.to_string(ast))
    end

    def inspect(string, opts \\ []) do
      opts = Keyword.put(opts, :limit, :infinity)
      IO.inspect(string, opts)
    end
  else
    def inspect_ast(_ast, _location) do
      :ok
    end

    def inspect(_string, _opts \\ []) do
      :ok
    end
  end
end
