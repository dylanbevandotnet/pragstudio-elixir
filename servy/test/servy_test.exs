defmodule ServyTest do
  use ExUnit.Case
  doctest Servy

  test "greets the world" do
    assert 1 + 2 == 3
    refute 1 + 2 == 2
  end
end
