defmodule MaxoAdapt.Log do
  alias MaxoAdapt.Config

  def inspect_ast(ast, location), do: do_inspect_ast(Config.debug(), ast, location)
  def inspect(string, opts \\ []), do: do_inspect(Config.debug(), string, opts)

  defp do_inspect_ast(true, ast, location) do
    MaxoAdapt.Log.inspect(ast, label: location)
    IO.puts(Macro.to_string(ast))
  end

  defp do_inspect_ast(false, _ast, _location) do
    :ok
  end

  defp do_inspect(true, string, opts) do
    opts = Keyword.put(opts, :limit, :infinity)
    IO.inspect(string, opts)
  end

  defp do_inspect(false, _string, _opts) do
    :ok
  end
end
