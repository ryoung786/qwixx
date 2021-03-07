defmodule Qwixx.Dice do
  alias Qwixx.Game

  defstruct [:red, :yellow, :blue, :green, :white]

  def roll(%Game{} = game) do
    locked_colors = Game.locked_colors(game)

    %{
      red: {:rand.uniform(6), :rand.uniform(6)},
      yellow: {:rand.uniform(6), :rand.uniform(6)},
      blue: {:rand.uniform(6), :rand.uniform(6)},
      green: {:rand.uniform(6), :rand.uniform(6)},
      white: {:rand.uniform(6), :rand.uniform(6)}
    }
    |> Map.drop(locked_colors)
  end
end
