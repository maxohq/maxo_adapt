defmodule MaxoAdapt.ProcDict do
  @moduledoc """
  Custom wrapper around process dictionary, that supports looking up values from ancestor processes
  The cost of walking the process tree is paid only on first miss, subsequent calls are cached in the
  local process dictionary.

  Primary use case is testing different implementation concurrently, with each test case having it's
  own configured adapter (and not affecting other test cases).

  The walking up the process tree ensures that we get proper results even if we start subprocesses,
  that do not share our process dictionary.

  Used for `:get_dict` strategy.
  """
  def put(key, value) do
    Process.put(key, value)
  end

  def get_with_ancestors(key) do
    with nil <- Process.get(key) do
      v = get_with_ancestors(self(), key)
      Process.put(key, v)
      v
    end
  end

  def get_with_ancestors(pid, key) do
    with nil <- get_value(pid, key) do
      pids = get_ancestors(pid) || []

      Enum.find_value(pids, fn ppid ->
        get_with_ancestors(ppid, key)
      end)
    end
  end

  defp get_ancestors(pid) do
    get_dict(pid) |> get(:"$ancestors")
  end

  defp get_value(pid, key) do
    get_dict(pid) |> get(key)
  end

  defp get_dict(pid) do
    Process.info(pid, :dictionary) |> elem(1)
  end

  ## adjusted `Keyword.get` that accepts non-atom keys
  @compile :inline_list_funcs
  defp get(keywords, key, default \\ nil) when is_list(keywords) do
    case :lists.keyfind(key, 1, keywords) do
      {^key, value} -> value
      false -> default
    end
  end
end
