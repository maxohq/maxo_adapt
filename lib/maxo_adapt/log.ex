defmodule MaxoAdapt.Log do
  def inspect_ast(ast, location) do
    MaxoAdapt.Log.inspect(ast, label: location)
    MaxoAdapt.Log.puts(Macro.to_string(ast))
  end

  def inspect(string, opts \\ []) do
    opts = Keyword.put(opts, :limit, :infinity)
    IO.inspect(string, opts)
  end

  def puts(str) do
    IO.puts(str)
  end
end
