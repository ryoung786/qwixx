defmodule Qwixx.Dice do
  alias Qwixx.{Dice, Game}

  defstruct red: {:rand.uniform(6), :rand.uniform(6)},
            yellow: {:rand.uniform(6), :rand.uniform(6)},
            blue: {:rand.uniform(6), :rand.uniform(6)},
            green: {:rand.uniform(6), :rand.uniform(6)},
            white: {:rand.uniform(6), :rand.uniform(6)}

  def roll(%Game{} = game) do
    locked_colors = Game.locked_colors(game)

    %Dice{}
    |> Map.drop(locked_colors)
  end
end
