defmodule MaxoAdaptTest do
  use ExUnit.Case
  use MnemeDefaults

  test "greeting" do
    auto_assert(MaxoAdapt.greeting())
  end
end
