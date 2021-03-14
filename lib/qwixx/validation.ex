defmodule Qwixx.Validation do
  alias Qwixx.{Game, Player, Scorecard}

  def validate_mark(%Game{} = game, player_name, color, num) do
    with {:ok, game} <- validate_shared_action(game, player_name),
         {:ok, game} <- color_is_unlocked(game, color),
         {:ok, game} <- num_matches_dice(game, color, num),
         {:ok, game} <- valid_color(game, color) do
      {:ok, game}
    else
      {:error, msg} -> {:error, msg}
    end
  end

  def validate_pass(%Game{} = game, player_name) do
    validate_shared_action(game, player_name)
  end

  defp validate_shared_action(%Game{} = game, player_name) do
    with {:ok, game} <- player_exists(game, player_name),
         {:ok, game} <- game_not_over(game),
         {:ok, game} <- game_has_started(game),
         {:ok, game} <- only_active_player_use_colors(game, player_name),
         {:ok, game} <- awaiting_players_move(game, player_name) do
      {:ok, game}
    else
      {:error, msg} -> {:error, msg}
    end
  end

  defp player_exists(game, name) do
    if name in Map.keys(game.players),
      do: {:ok, game},
      else: {:error, :player_does_not_exist}
  end

  defp valid_color(game, color) when color in ~w(red yellow blue green)a, do: {:ok, game}
  defp valid_color(_game, _color), do: {:error, :invalid_color}

  defp game_not_over(%{status: :game_over}), do: {:error, :game_is_over}
  defp game_not_over(game), do: {:ok, game}

  defp game_has_started(%{status: :awaiting_start}), do: {:error, :game_not_started}
  defp game_has_started(game), do: {:ok, game}

  defp only_active_player_use_colors(%Game{status: :colors} = game, player_name) do
    if Game.active_player_name(game) == player_name,
      do: {:ok, game},
      else: {:error, :not_active_player}
  end

  defp only_active_player_use_colors(game, _player_name), do: {:ok, game}

  defp awaiting_players_move(%Game{status: :colors} = game, _player_name), do: {:ok, game}

  defp awaiting_players_move(%Game{} = game, player_name) do
    case Map.get(game.turn_actions, player_name) do
      :awaiting_choice -> {:ok, game}
      _ -> {:error, :player_already_went}
    end
  end

  defp color_is_unlocked(%Game{} = game, color) do
    if color not in Game.locked_colors(game),
      do: {:ok, game},
      else: {:error, :color_is_locked}
  end

  defp num_matches_dice(%Game{status: :white} = game, _color, num) do
    {a, b} = game.dice.white

    if a + b == num, do: {:ok, game}, else: {:error, :number_not_dice_sum}
  end

  defp num_matches_dice(%Game{status: :colors} = game, color, num) do
    {a, b} = game.dice.white
    {c, d} = Map.get(game.dice, color)

    if num in [a + c, a + d, b + c, b + d],
      do: {:ok, game},
      else: {:error, :number_not_dice_sum}
  end

  def valid_moves(%Game{} = game, player_name) do
    with %Player{} = player <- Map.get(game.players, player_name) do
      marks =
        Scorecard.rows(player.scorecard)
        |> Enum.reduce([], fn {color, _row}, acc ->
          2..12
          |> Enum.reduce(acc, fn i, acc ->
            case Game.mark(game, player_name, color, i) do
              {:ok, _} -> [{color, i} | acc]
              _ -> acc
            end
          end)
        end)

      case Game.pass(game, player_name) do
        {:ok, _} -> [:pass | marks]
        _ -> marks
      end
    else
      nil -> []
    end
  end
end
