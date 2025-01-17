defmodule Qwixx.Scorecard do
  @moduledoc false
  alias __MODULE__

  @colors ~w/red yellow blue green/a
  @locks [{:red, 12}, {:yellow, 12}, {:green, 2}, {:blue, 2}]
  @scoring_scale [0, 1, 3, 6, 10, 15, 21, 28, 36, 45, 55, 66, 78]
  @pass_multiplier -5
  @pass_limit 4

  @derive Jason.Encoder
  defstruct red: [], yellow: [], blue: [], green: [], pass_count: 0

  def mark(%Scorecard{} = scorecard, color, num) do
    row = Map.get(scorecard, color)

    cond do
      num in row -> {:error, :already_marked}
      color in ~w/red yellow/a && num < Enum.max(row, fn -> -1 end) -> {:error, :left_to_right}
      color in ~w/blue green/a && num > Enum.min(row, fn -> 99 end) -> {:error, :left_to_right}
      {color, num} in @locks && Enum.count(row) < 5 -> {:error, :lock_min}
      true -> {:ok, Map.put(scorecard, color, [num | row])}
    end
  end

  def pass(%Scorecard{pass_count: num}) when num > @pass_limit, do: {:error, :at_pass_limit}
  def pass(%Scorecard{pass_count: num} = scorecard), do: {:ok, %{scorecard | pass_count: num + 1}}

  def score(%Scorecard{} = scorecard) do
    row_scores = scorecard |> Map.take(@colors) |> Enum.map(&score_row/1)
    pass_total = scorecard.pass_count * @pass_multiplier
    row_total = row_scores |> Enum.map(&elem(&1, 1)) |> Enum.sum()
    %{rows: Map.new(row_scores), pass: pass_total, total: row_total + pass_total}
  end

  def lock_bonus?(color, row) do
    n = if color in ~w/red yellow/a, do: 12, else: 2
    n in row
  end

  defp score_row({color, row}) do
    bonus = if lock_bonus?(color, row), do: 1, else: 0
    {color, Enum.at(@scoring_scale, Enum.count(row) + bonus)}
  end

  def rows(%Scorecard{} = scorecard), do: Map.take(scorecard, @colors)
end
