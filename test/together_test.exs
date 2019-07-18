defmodule TogetherTest do
  use ExUnit.Case
  doctest Together

  test "greets the world" do
    assert Together.hello() == :world
  end
end
