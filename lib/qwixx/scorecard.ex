defmodule Qwixx.Scorecard do
  alias Qwixx.ScorecardRow, as: Row

  @colors ~w(red yellow blue green)a
  @pass_score -5

  defstruct red: Row.new(:red),
            yellow: Row.new(:yellow),
            blue: Row.new(:blue),
            green: Row.new(:green),
            pass: 0

  def mark(%__MODULE__{} = scorecard, color, num) when color in @colors do
    row = Map.get(scorecard, color)

    with {:ok, row} <- Row.mark(row, num) do
      Map.put(scorecard, color, row)
    else
      {:error, reasons} -> {:error, reasons}
    end
  end

  def score(%__MODULE__{} = scorecard) do
    row_scores =
      scorecard
      |> Map.from_struct()
      |> Map.take(@colors)
      |> Enum.map(fn {color, row} -> {color, Row.score(row)} end)

    pass_total = scorecard.pass * @pass_score

    row_total = Enum.reduce(row_scores, 0, fn {_, score}, sum -> sum + score end)
    %{rows: Map.new(row_scores), total: row_total + pass_total}
  end

  def rows(%__MODULE__{} = scorecard), do: Map.take(scorecard, @colors)
end
