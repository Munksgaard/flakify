defmodule FlakifyTest do
  use ExUnit.Case
  doctest Flakify

  test "greets the world" do
    assert Flakify.hello() == :world
  end
end
