defmodule Redex.Command.PttlTest do
  use ExUnit.Case

  import Redex.Protocol.State
  import Redex.Mock.State
  import Redex.Command.PTTL

  setup_all do
    [state: mock_state()]
  end

  setup %{state: state} do
    {:atomic, :ok} = :mnesia.clear_table(:redex)
    reset_state(state)
    :ok
  end

  test "PTTL of non existing key", %{state: state} do
    result = exec(["a"], state) |> get_output()
    assert result == ":-2\r\n"
  end

  test "PTTL of existing key without expiry", %{state: state} do
    :ok = :mnesia.dirty_write({:redex, {0, "a"}, "123", nil})
    result = exec(["a"], state) |> get_output()
    assert result == ":-1\r\n"
  end

  test "PTTL of existing key with expiry", %{state: state} do
    expiry = System.os_time(:millisecond) + 1000
    :ok = :mnesia.dirty_write({:redex, {0, "a"}, "123", expiry})
    result = exec(["a"], state) |> get_output()
    assert result == ":1000\r\n"
  end

  test "PTTL of a key from db 1", %{state: state} do
    :ok = :mnesia.dirty_write({:redex, {1, "a"}, "123", nil})
    result = exec(["a"], state(state, db: 1)) |> get_output()
    assert result == ":-1\r\n"
  end

  test "PTTL of an expired key", %{state: state} do
    expiry = System.os_time(:millisecond) - 1
    :ok = :mnesia.dirty_write({:redex, {0, "a"}, "123", expiry})
    result = exec(["a"], state) |> get_output()
    assert result == ":-2\r\n"
  end

  test "PTTL with wrong number of arguments", %{state: state} do
    result = exec(["a", "b"], state) |> get_output()
    assert result == "-ERR wrong number of arguments for 'PTTL' command\r\n"
  end
end
