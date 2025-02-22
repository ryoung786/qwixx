defmodule Qwixx.ScorecardTest do
  use ExUnit.Case

  alias Qwixx.Scorecard

  describe "mark" do
    test "red row" do
      card = %Scorecard{} |> mark!(:red, 3) |> mark!(:red, 5)
      assert card.red == [5, 3]
    end

    test "blue row" do
      card = mark!(%Scorecard{}, :blue, 3)
      assert card.blue == [3]
      assert {:error, :left_to_right} = Scorecard.mark(card, :blue, 5)
    end

    test "also locks when marking red 12" do
      card = %Scorecard{} |> mark!(:red, 2) |> mark!(:red, 3) |> mark!(:red, 4) |> mark!(:red, 5) |> mark!(:red, 6)
      card = mark!(card, :red, 12)

      assert :lock in card.red
      assert card.red -- [2, 3, 4, 5, 6, 12, :lock] == []
    end

    test "also locks when marking blue 2" do
      card = %Scorecard{} |> mark!(:blue, 9) |> mark!(:blue, 8) |> mark!(:blue, 7) |> mark!(:blue, 6) |> mark!(:blue, 5)
      card = mark!(card, :blue, 2)

      assert :lock in card.blue
      assert card.blue -- [9, 8, 7, 6, 5, 2, :lock] == []
    end
  end

  describe "score" do
    test "total" do
      card =
        %Scorecard{
          red: [2, 3, 4, 8],
          yellow: [3, 9, 11],
          blue: [12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, :lock],
          green: [],
          pass_count: 0
        }

      assert Scorecard.score(card).total == 94
    end

    test "with passes" do
      card =
        %Scorecard{
          red: [2, 3, 4, 8],
          yellow: [3, 9, 11],
          blue: [12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2, :lock],
          green: [],
          pass_count: 2
        }

      assert Scorecard.score(card).total == 84
    end
  end

  defp mark!(scorecard, color, num) do
    {:ok, scorecard} = Scorecard.mark(scorecard, color, num)
    scorecard
  end
end
