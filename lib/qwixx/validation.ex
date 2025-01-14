defmodule Qwixx.Validation do
  @moduledoc false
  alias Qwixx.Game
  alias Qwixx.Scorecard

  def validate_mark(%Game{} = game, player_name, color, num) do
    with {:ok, game} <- validate_shared_action(game, player_name),
         {:ok, game} <- color_is_unlocked(game, color),
         {:ok, game} <- num_matches_dice(game, color, num) do
      valid_color(game, color)
    end
  end

  def validate_pass(%Game{} = game, player_name) do
    validate_shared_action(game, player_name)
  end

  defp validate_shared_action(%Game{} = game, player_name) do
    with {:ok, game} <- player_exists(game, player_name),
         {:ok, game} <- game_not_over(game),
         {:ok, game} <- game_has_started(game),
         {:ok, game} <- only_active_player_use_colors(game, player_name) do
      awaiting_players_move(game, player_name)
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
    %{turn_order: [active_player_name | _]} = game

    if active_player_name == player_name,
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
    if color in game.locked_colors,
      do: {:error, :color_is_locked},
      else: {:ok, game}
  end

  defp num_matches_dice(%Game{} = game, color, num) do
    {w1, w2} = game.dice.white
    c = Map.get(game.dice, color)
    possible = if game.status == :white, do: [w1 + w2], else: [c + w1, c + w2]
    if num in possible, do: {:ok, game}, else: {:error, :number_not_dice_sum}
  end

  def valid_moves(%Game{} = game, player_name) do
    case Map.get(game.players, player_name) do
      %Scorecard{} = scorecard ->
        marks =
          scorecard
          |> Scorecard.rows()
          |> Enum.reduce([], fn {color, _row}, acc ->
            Enum.reduce(2..12, acc, fn i, acc ->
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

      nil ->
        []
    end
  end
end
