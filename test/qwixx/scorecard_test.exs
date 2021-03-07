defmodule Qwixx.ScorecardTest do
  use ExUnit.Case

  alias Qwixx.Scorecard, as: Card
  alias Qwixx.ScorecardRow, as: Row

  describe "mark" do
    test "red row" do
      card = Card.mark!(%Card{}, :red, 3) |> Card.mark!(:red, 5)
      assert Row.count_checks(card.red) == 2
    end
  end

  describe "score" do
    test "total" do
      card =
        card_helper(%{
          red: [2, 3, 4, 8],
          yellow: [3, 9, 11],
          blue: [12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2],
          green: [],
          pass_count: 0
        })

      assert Card.score(card).total == 94
    end

    test "with passes" do
      card =
        card_helper(%{
          red: [2, 3, 4, 8],
          yellow: [3, 9, 11],
          blue: [12, 11, 10, 9, 8, 7, 6, 5, 4, 3, 2],
          green: [],
          pass_count: 2
        })

      assert Card.score(card).total == 84
    end
  end

  defp card_helper(%{red: red, yellow: yellow, blue: blue, green: green, pass_count: pass}) do
    %Card{
      red: mark(%Card{}.red, red),
      yellow: mark(%Card{}.yellow, yellow),
      blue: mark(%Card{}.blue, blue),
      green: mark(%Card{}.green, green),
      pass_count: pass
    }
  end

  defp mark(row, arr) when is_list(arr) do
    Enum.reduce(arr, row, fn num, row ->
      Row.mark!(row, num)
    end)
  end
end
