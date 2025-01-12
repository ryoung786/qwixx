defmodule Qwixx.Player do
  @moduledoc false
  alias Qwixx.Scorecard

  defstruct name: nil, scorecard: %Scorecard{}

  def mark(%__MODULE__{} = player, color, num) do
    case Scorecard.mark(player.scorecard, color, num) do
      {:ok, scorecard} -> {:ok, %{player | scorecard: scorecard}}
      err -> err
    end
  end

  def pass(%__MODULE__{scorecard: scorecard} = player) do
    case Scorecard.pass(scorecard) do
      {:ok, card} -> {:ok, %{player | scorecard: card}}
      err -> err
    end
  end

  def score(%__MODULE__{scorecard: scorecard}), do: Scorecard.score(scorecard)
end
