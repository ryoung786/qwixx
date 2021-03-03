defmodule Qwixx.Scorecard do
  alias Qwixx.ScorecardRow, as: Row

  @colors ~w(red yellow blue green)a

  defstruct red: Row.new(:red),
            yellow: Row.new(:yellow),
            blue: Row.new(:blue),
            green: Row.new(:green)

  def mark(%__MODULE__{} = scorecard, color, num) when color in @colors do
    row = Map.get(scorecard, color)

    with {:ok, row} <- Row.mark(row, num) do
      Map.put(scorecard, color, row)
    else
      {:error, reasons} -> {:error, reasons}
    end
  end

  def score(%__MODULE__{} = scorecard) do
    scores =
      scorecard
      |> Map.from_struct()
      |> Enum.map(fn {color, row} -> {color, Row.score(row)} end)

    total = Enum.reduce(scores, 0, fn {_, score}, sum -> sum + score end)
    %{rows: Map.new(scores), total: total}
  end
end
