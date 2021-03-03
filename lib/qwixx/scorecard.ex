defmodule Qwixx.Scorecard do
  alias Qwixx.ScorecardRow, as: Row
  # @num_status ~w(open yes no)
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
end
