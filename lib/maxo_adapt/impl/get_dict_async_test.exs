defmodule MaxoAdapt.Impl.GetDictAsyncTest do
  use ExUnit.Case
  use MnemeDefaults

  defmodule Repo do
    use MaxoAdapt, mode: :get_dict

    behaviour do
      @callback info() :: any()
    end
  end

  defmodule Repo1 do
    @behaviour Repo

    @impl Repo
    def info(), do: "repo1"
  end

  defmodule Repo2 do
    @behaviour Repo

    @impl Repo
    def info(), do: "repo2"
  end

  defmodule Repo3 do
    @behaviour Repo

    @impl Repo
    def info(), do: "repo3"
  end

  defmodule Repo4 do
    @behaviour Repo

    @impl Repo
    def info(), do: "repo4"
  end

  test "`configure` in subprocesses does not affect parents" do
    Repo.configure(Repo1)
    assert Repo.info() == "repo1"

    t1 =
      Task.async(fn ->
        Repo.configure(Repo2)
        assert Repo.info() == "repo2"
      end)

    t2 =
      Task.async(fn ->
        Repo.configure(Repo3)
        assert Repo.info() == "repo3"
      end)

    t3 =
      Task.async(fn ->
        Repo.configure(Repo4)
        assert Repo.info() == "repo4"

        t =
          Task.async(fn ->
            assert Repo.info() == "repo4"
          end)

        Task.await(t)
      end)

    t4 =
      Task.async(fn ->
        assert Repo.info() == "repo1"

        t =
          Task.async(fn ->
            assert Repo.info() == "repo1"
          end)

        Task.await(t)
      end)

    Task.await_many([t1, t2, t3, t4])
    assert Repo.info() == "repo1"
  end
end
