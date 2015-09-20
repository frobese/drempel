defmodule DrempelTest do
  use ExUnit.Case, async: true

  import Drempel, only: [get: 2, fetch: 2, update: 2, put: 2]

  test "empty defaults" do
    assert get(:default, :foo) == 0
    assert fetch(:default, :foo) == :error
  end

  test "default backoffs" do
    assert get(:default, :bar) == 0
    :timer.sleep(1_000)
    assert get(:default, :bar) == 0

    assert put(:default, :bar) == :ok
    assert_in_delta get(:default, :bar), 1_000, 50
    :timer.sleep(500)
    assert_in_delta get(:default, :bar), 500, 50
    :timer.sleep(500)
    assert get(:default, :bar) == 0

    assert put(:default, :bar) == :ok
    assert_in_delta get(:default, :bar), 3_000, 50
    assert put(:default, :bar) == :ok
    assert_in_delta get(:default, :bar), 7_000, 50
  end

  test "independent buckets" do
    assert get(:default, :baz) == 0
    assert get(:other, :baz) == 0

    assert put(:default, :baz) == :ok
    assert_in_delta get(:default, :baz), 1_000, 50
    assert get(:other, :baz) == 0

    assert put(:default, :baz) == :ok
    assert_in_delta get(:default, :baz), 3_000, 50
    assert get(:other, :baz) == 0
  end

  test "exponential backoff values" do
    assert get(:default, :qux) == 0

    assert put(:default, :qux) == :ok
    assert_in_delta get(:default, :qux), 1_000, 500
    assert put(:default, :qux) == :ok
    assert_in_delta get(:default, :qux), 3_000, 500
    assert put(:default, :qux) == :ok
    assert_in_delta get(:default, :qux), 7_000, 500

    assert put(:default, :qux) == :ok
    assert_in_delta get(:default, :qux), 15_000, 500
    assert put(:default, :qux) == :ok
    assert_in_delta get(:default, :qux), 31_000, 500
    assert put(:default, :qux) == :ok
    assert_in_delta get(:default, :qux), 63_000, 500

    assert put(:default, :qux) == :ok
    assert_in_delta get(:default, :qux), 127_000, 50
    assert put(:default, :qux) == :ok
    assert_in_delta get(:default, :qux), 255_000, 50
    assert put(:default, :qux) == :ok
    assert_in_delta get(:default, :qux), 511_000, 50

    assert put(:default, :qux) == :ok
    assert_in_delta get(:default, :qux), 1_023_000, 50
    assert put(:default, :qux) == :ok
    assert_in_delta get(:default, :qux), 2_047_000, 50
    assert put(:default, :qux) == :ok
    assert_in_delta get(:default, :qux), 4_095_000, 50

    assert put(:default, :qux) == :ok
    assert_in_delta get(:default, :qux), 8_191_000, 50
    assert put(:default, :qux) == :ok
    assert_in_delta get(:default, :qux), 16_383_000, 50
    assert put(:default, :qux) == :ok
    assert_in_delta get(:default, :qux), 16_383_000, 50
    assert put(:default, :qux) == :ok
    assert_in_delta get(:default, :qux), 16_383_000, 50
  end

  test "update backoff" do
    assert get(:default, :norf) == 0

    assert update(:default, :norf) == 0
    assert_in_delta update(:default, :norf), 1_000, 50
    assert_in_delta update(:default, :norf), 1_000, 50
    assert_in_delta update(:default, :norf), 1_000, 50

    :timer.sleep(1050)
    assert update(:default, :norf) == 0
    assert_in_delta update(:default, :norf), 3_000, 50
    assert_in_delta update(:default, :norf), 3_000, 50
    assert_in_delta update(:default, :norf), 3_000, 50
  end
end
