defmodule Airbrakex.TestPlug do
  use Airbrakex.Plug

  def call(_conn, _opts) do
    IO.inspect("test", [], "")
  end
end

defmodule Airbrakex.PlugTest do
  use Airbrakex.TestCase
  use Plug.Test

  def ignore_function(_error) do
    false
  end

  test "notifies with request url in context" do
    notify fn -> Airbrakex.TestPlug.call(conn(:get, "/wat"), %{}) end, fn _conn, params ->
      %{"context" => context} = params
      assert "http://www.example.com/wat" == Map.get(context, "url")
    end
  end

  test "ignore with {module, fun} tuple" do
    Application.put_env(:airbrakex, :ignore, {Airbrakex.PlugTest, :ignore_function})
    try do
      notify fn -> Airbrakex.TestPlug.call(conn(:get, "/wat"), %{}) end, fn(_conn, _params) -> :nothing end
    after
      Application.delete_env(:airbrakex, :ignore)
    end
  end
end
