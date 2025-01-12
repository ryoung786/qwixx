defmodule Qwixx.Game do
  @moduledoc false
  alias Qwixx.Game
  alias Qwixx.Player
  alias Qwixx.Validation

  defstruct players: %{},
            turn_order: [],
            status: :awaiting_start,
            dice: nil,
            locked_colors: [],
            turn_actions: %{}

  @pass_limit 4
  @locked_color_limit 2

  def add_player(%Game{} = game, name) do
    if name in Map.keys(game.players) do
      {:error, :player_name_taken}
    else
      players = Map.put(game.players, name, %Player{name: name})
      added_to_end = game.turn_order ++ [name]
      %{game | players: players, turn_order: added_to_end}
    end
  end

  def remove_player(%Game{} = game, name) do
    if name in Map.keys(game.players) do
      players = Map.delete(game.players, name)
      removed = List.delete(game.turn_order, name)
      %{game | players: players, turn_order: removed}
    else
      {:error, :player_not_in_game}
    end
  end

  def start(%Game{players: players} = game) when map_size(players) > 0 do
    game
    |> Map.put(:status, :awaiting_start)
    |> reset_scorecards()
    |> shuffle_player_order()
    |> advance()
  end

  defp roll(%Game{} = game) do
    dice = %{
      red: :rand.uniform(6),
      yellow: :rand.uniform(6),
      blue: :rand.uniform(6),
      green: :rand.uniform(6),
      white: {:rand.uniform(6), :rand.uniform(6)}
    }

    %{game | dice: Map.drop(dice, game.locked_colors)}
  end

  def mark(%Game{} = game, player_name, color, num) do
    with {:ok, game} <- Validation.validate_mark(game, player_name, color, num),
         player = game.players[player_name],
         {:ok, player} <- Player.mark(player, color, num) do
      game = put_in(game.players[player.name], player)
      game = put_in(game.turn_actions[player.name], {color, num})
      {:ok, maybe_advance(game)}
    end
  end

  def pass(%Game{} = game, player_name) do
    with {:ok, game} <- Validation.validate_pass(game, player_name) do
      player = game.players[player_name]

      cond do
        game.status == :white ->
          pass_on_white_dice(game, player)

        game.turn_actions[player_name] == :pass ->
          take_pass_penalty(game, player)

        "pass on colored dice, but marked the white dice so it's ok" ->
          {:ok, maybe_advance(game)}
      end
    end
  end

  defp pass_on_white_dice(game, player) do
    game = put_in(game.turn_actions[player.name], :pass)
    {:ok, maybe_advance(game)}
  end

  defp take_pass_penalty(game, player) do
    case Player.pass(player) do
      {:ok, player} ->
        game = put_in(game.players[player.name], player)
        {:ok, maybe_advance(game)}

      {:error, msg} ->
        {:error, msg}
    end
  end

  defp maybe_advance(%Game{} = game) do
    everyone_has_made_choice =
      Enum.all?(game.turn_actions, fn {_name, action} -> action != :awaiting_choice end)

    if everyone_has_made_choice, do: advance(game), else: game
  end

  defp advance(%Game{} = game) do
    locked_colors =
      Enum.reduce(game.players, MapSet.new(), fn {_name, %{scorecard: card}}, acc ->
        acc = if 12 in card.red, do: MapSet.put(acc, :red), else: acc
        acc = if 12 in card.yellow, do: MapSet.put(acc, :yellow), else: acc
        acc = if 2 in card.blue, do: MapSet.put(acc, :blue), else: acc
        acc = if 2 in card.green, do: MapSet.put(acc, :green), else: acc
        acc
      end)

    game = %{game | locked_colors: MapSet.to_list(locked_colors)}

    cond do
      game_over?(game) -> %{game | status: :game_over}
      game.status == :white -> %{game | status: :colors}
      true -> next_turn(game)
    end
  end

  defp next_turn(game) do
    game = %{game | status: :white}
    [a | rest] = game.turn_order

    game
    |> Map.put(:turn_order, rest ++ [a])
    |> reset_turn_actions()
    |> roll()
  end

  defp reset_turn_actions(%Game{} = game) do
    turn_actions =
      Map.new(game.players, fn {name, _} -> {name, :awaiting_choice} end)

    %{game | turn_actions: turn_actions}
  end

  defp game_over?(%Game{players: players} = game) do
    any_players_hit_pass_limit =
      Enum.any?(players, fn {_, %{scorecard: card}} -> card.pass_count >= @pass_limit end)

    any_players_hit_pass_limit || Enum.count(game.locked_colors) >= @locked_color_limit
  end

  defp shuffle_player_order(%Game{players: players} = game) do
    names = Map.keys(players)
    %{game | turn_order: Enum.shuffle(names)}
  end

  def locked_colors(%Game{} = game), do: game.locked_colors

  defp reset_scorecards(%Game{players: players} = game) do
    players =
      Map.new(players, fn {name, _} ->
        {name, %Player{name: name}}
      end)

    %{game | players: players}
  end

  def active_player_name(%Game{turn_order: [player_name | _]}), do: player_name

  def scores(%Game{players: players}) do
    Map.new(players, fn {name, p} ->
      {name, Player.score(p)}
    end)
  end
end
