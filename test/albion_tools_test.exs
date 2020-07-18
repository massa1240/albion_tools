defmodule AlbionToolsTest do
  use ExUnit.Case
  doctest AlbionTools

  test "greets the world" do
    assert AlbionTools.hello() == :world
  end
end
