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

  def start(%Game{players: players}) when map_size(players) > 0 do
    players
    |> Enum.reduce(%Game{}, fn {name, _}, game -> Game.add_player(game, name) end)
    |> Map.put(:status, :awaiting_start)
    |> Map.put(:turn_order, players |> Map.keys() |> Enum.shuffle())
    |> advance()
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
          game = put_in(game.turn_actions[player.name], :pass)
          {:ok, maybe_advance(game)}

        game.turn_actions[player_name] == :pass ->
          take_pass_penalty(game, player)

        "pass on colored dice, but marked the white dice so it's ok" ->
          {:ok, maybe_advance(game)}
      end
    end
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
    pass_limit_hit = Enum.any?(game.players, fn {_, %{scorecard: card}} -> card.pass_count >= @pass_limit end)

    cond do
      pass_limit_hit || Enum.count(game.locked_colors) >= @locked_color_limit -> %{game | status: :game_over}
      game.status == :white -> %{game | status: :colors}
      true -> next_turn(game)
    end
  end

  defp next_turn(%{turn_order: [a | rest]} = game) do
    dice = %{
      red: :rand.uniform(6),
      yellow: :rand.uniform(6),
      blue: :rand.uniform(6),
      green: :rand.uniform(6),
      white: {:rand.uniform(6), :rand.uniform(6)}
    }

    game
    |> Map.put(:status, :white)
    |> Map.put(:turn_order, rest ++ [a])
    |> Map.put(:turn_actions, game.players |> Map.keys() |> Map.new(&{&1, :awaiting_choice}))
    |> Map.put(:dice, Map.drop(dice, game.locked_colors))
  end
end
