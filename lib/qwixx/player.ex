defmodule Qwixx.Player do
  alias Qwixx.{Player, Scorecard}

  defstruct name: "", scorecard: %Scorecard{}

  def mark(%__MODULE__{} = player, color, num) do
    with {:ok, scorecard} <- Scorecard.mark(player.scorecard, color, num) do
      {:ok, %{player | scorecard: scorecard}}
    else
      {:error, reasons} -> {:error, reasons}
    end
  end

  def mark!(%__MODULE__{} = player, color, num) do
    {:ok, player} = mark(player, color, num)
    player
  end

  def pass(%__MODULE__{scorecard: scorecard} = player) do
    case Scorecard.pass(scorecard) do
      {:ok, card} -> {:ok, %{player | scorecard: card}}
      err -> err
    end
  end

  def score(%__MODULE__{scorecard: scorecard}), do: Scorecard.score(scorecard)

  def lock_row(%Player{} = player, color) do
    card = Scorecard.lock_row(player.scorecard, color)
    %{player | scorecard: card}
  end
end
