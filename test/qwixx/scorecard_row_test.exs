defmodule Qwixx.ScorecardRowTest do
  use ExUnit.Case

  alias Qwixx.ScorecardRow, as: Row

  describe "new" do
    test "red row" do
      vals = Row.new(:red).values |> Enum.map(fn %{val: v} -> v end)
      assert List.first(vals) == 2
      assert List.last(vals) == 12
    end

    test "green row" do
      vals = Row.new(:green).values |> Enum.map(fn %{val: v} -> v end)
      assert List.first(vals) == 12
      assert List.last(vals) == 2
    end
  end

  describe "lock" do
    test "new row" do
      row = Row.new(:red) |> Row.lock()
      assert row.locked
    end
  end

  describe "mark validation" do
    test "locked row has error" do
      row = Row.new(:red) |> Row.lock()
      assert {:error, [:locked]} = Row.mark(row, 4)
    end

    test "invalid number" do
      assert {:error, [:num_out_of_range]} = Row.mark(Row.new(:red), 14)
      assert {:error, [:num_out_of_range]} = Row.mark(Row.new(:red), 1)
    end

    test "number already x'd out" do
      row = Row.new(:red) |> Row.mark!(5)
      assert {:error, [:num_not_open]} = Row.mark(row, 3)

      row = Row.new(:blue) |> Row.mark!(9)
      assert {:error, [:num_not_open]} = Row.mark(row, 11)
    end

    test "lock with less than 4" do
      row = Row.new(:red) |> Row.mark!(5)
      assert {:error, [:not_enough_to_lock]} = Row.mark(row, 12)

      row = Row.new(:blue) |> Row.mark!(9)
      assert {:error, [:not_enough_to_lock]} = Row.mark(row, 2)
    end

    test "multiple errors" do
      row = Row.new(:red) |> Row.mark!(5) |> Row.lock()
      {:error, reasons} = Row.mark(row, 12)
      assert :locked in reasons
      assert :not_enough_to_lock in reasons
    end
  end

  describe "mark" do
    test "red locks after 12" do
      row = Row.new(:red) |> mark([5, 6, 7, 9])
      assert {:ok, %{locked: true}} = Row.mark(row, 12)
    end

    test "blue locks after 2" do
      row = Row.new(:blue) |> mark([12, 10, 9, 3])
      assert {:ok, %{locked: true}} = Row.mark(row, 2)
    end
  end

  describe "count checks" do
    test "multiple" do
      row = Row.new(:red)
      assert row |> Row.count_checks() == 0
      assert row |> mark([2, 3, 4, 5]) |> Row.count_checks() == 4
    end
  end

  describe "score" do
    test "lock bonus" do
      row = Row.new(:red)
      assert Row.score(row) == 0
      row = mark(row, [3, 4, 7, 8])
      assert Row.score(row) == 10
      row = mark(row, [9, 11])
      assert Row.score(row) == 21
      assert row |> Row.mark!(12) |> Row.score() == 36
    end
  end

  defp mark(row, arr) when is_list(arr) do
    Enum.reduce(arr, row, fn num, row ->
      Row.mark!(row, num)
    end)
  end
end
