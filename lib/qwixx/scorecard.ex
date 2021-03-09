defmodule Qwixx.Scorecard do
  alias Qwixx.Scorecard
  alias Qwixx.ScorecardRow, as: Row

  @colors ~w(red yellow blue green)a
  @pass_score -5
  @pass_limit 4

  defstruct red: Row.new(:red),
            yellow: Row.new(:yellow),
            blue: Row.new(:blue),
            green: Row.new(:green),
            pass_count: 0

  def mark(%Scorecard{} = _scorecard, color, _num) when color not in @colors do
    {:error, [:invalid_color]}
  end

  def mark(%Scorecard{} = scorecard, color, num) do
    row = Map.get(scorecard, color)

    with {:ok, row} <- Row.mark(row, num) do
      {:ok, Map.put(scorecard, color, row)}
    else
      {:error, reasons} -> {:error, reasons}
    end
  end

  def mark!(%Scorecard{} = scorecard, color, num) do
    {:ok, scorecard} = mark(scorecard, color, num)
    scorecard
  end

  def pass(%Scorecard{pass_count: num}) when num >= @pass_limit, do: {:error, :at_pass_limit}

  def pass(%Scorecard{pass_count: num} = scorecard),
    do: {:ok, %{scorecard | pass_count: num + 1}}

  def score(%Scorecard{} = scorecard) do
    row_scores =
      scorecard
      |> Map.from_struct()
      |> Map.take(@colors)
      |> Enum.map(fn {color, row} -> {color, Row.score(row)} end)

    pass_total = scorecard.pass_count * @pass_score

    row_total = Enum.reduce(row_scores, 0, fn {_, score}, sum -> sum + score end)
    %{rows: Map.new(row_scores), pass: pass_total, total: row_total + pass_total}
  end

  def rows(%Scorecard{} = scorecard), do: Map.take(scorecard, @colors)

  def lock_row(%Scorecard{} = scorecard, color) do
    row = Map.get(scorecard, color) |> Row.lock()
    Map.put(scorecard, color, row)
  end
end
