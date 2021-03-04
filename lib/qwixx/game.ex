defmodule Qwixx.Game do
  alias Qwixx.Scorecard

  defstruct players: []

  def add_player(%__MODULE__{} = game, name) do
    player = %{name: name, scorecard: %Scorecard{}}
    %{game | players: [player | game.players]}
  end

  defp shuffle_player_order(%__MODULE__{players: players} = game),
    do: %{game | players: Enum.shuffle(players)}

  def start(%__MODULE__{players: players} = game) when length(players) > 0 do
    game = shuffle_player_order(game)
    game
  end

  def roll(%__MODULE__{} = game) do
    %{
      red: {:rand.uniform(6), :rand.uniform(6)},
      yellow: {:rand.uniform(6), :rand.uniform(6)},
      blue: {:rand.uniform(6), :rand.uniform(6)},
      green: {:rand.uniform(6), :rand.uniform(6)},
      white: {:rand.uniform(6), :rand.uniform(6)}
    }
    |> Map.drop(locked_colors(game))
  end

  defp locked_colors(%__MODULE__{players: []}), do: []

  defp locked_colors(%__MODULE__{players: [player | _]}) do
    Scorecard.rows(player.scorecard)
    |> Enum.filter(fn {_color, row} -> row.locked end)
    |> Map.new()
    |> Map.keys()
  end
end
