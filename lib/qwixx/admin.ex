defmodule Qwixx.Admin do
  @moduledoc false

  alias Qwixx.Dice
  alias Qwixx.Game
  alias Qwixx.Scorecard

  def set_almost_game_over(%Game{} = game) do
    dice = %Dice{red: 6, yellow: 6, blue: 1, green: 1, white: {6, 6}}
    turn_actions = game.players |> Map.keys() |> Map.new(&{&1, :awaiting_choice})

    players =
      Map.new(game.players, fn {name, _scorecard} ->
        scorecard = %Scorecard{
          red: [2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
          yellow: [2, 3, 4, 5, 6, 7, 8, 9, 10, 11],
          blue: [12, 11, 10, 9, 8, 7, 6, 5, 4, 3],
          green: [12, 11, 10, 9, 8, 7, 6, 5, 4, 3],
          pass_count: 3
        }

        scorecard = %{scorecard | score: Scorecard.score(scorecard)}
        {name, scorecard}
      end)

    %{game | players: players, dice: dice, locked_colors: [], status: :white, turn_actions: turn_actions}
  end
end
