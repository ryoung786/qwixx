defmodule Qwixx.Game do
  @moduledoc false
  alias Qwixx.Dice
  alias Qwixx.Game
  alias Qwixx.Scorecard
  alias Qwixx.Validation

  @derive Jason.Encoder
  defstruct players: %{},
            turn_order: [],
            # game status: [:awaiting_start, :white, :colors, :awaiting_roll, :game_over]
            status: :awaiting_start,
            dice: %Dice{},
            locked_colors: [],
            turn_actions: %{},
            event_history: []

  @pass_limit 4
  @locked_color_limit 2

  def add_player!(game, name), do: game |> add_player(name) |> elem(1)
  def remove_player!(game, name), do: game |> remove_player(name) |> elem(1)

  def add_player(%Game{} = game, name) do
    if name in Map.keys(game.players) do
      {:error, :player_name_taken}
    else
      players = Map.put(game.players, name, %Scorecard{})
      added_to_end = game.turn_order ++ [name]
      game = %{game | players: players, turn_order: added_to_end}
      {:ok, add_event(game, :player_added, name)}
    end
  end

  def remove_player(%Game{} = game, name) do
    if name in Map.keys(game.players) do
      players = Map.delete(game.players, name)
      removed = List.delete(game.turn_order, name)
      game = %{game | players: players, turn_order: removed}
      {:ok, add_event(game, :player_removed, name)}
    else
      {:error, :player_not_in_game}
    end
  end

  def start(%Game{players: players}) when map_size(players) > 0 do
    players
    |> Enum.reduce(%Game{}, fn {name, _}, game -> add_player!(game, name) end)
    |> Map.put(:status, :awaiting_start)
    |> Map.put(:turn_order, players |> Map.keys() |> Enum.shuffle())
    |> add_event(:game_started, nil)
    |> advance()
  end

  def mark(%Game{} = game, player_name, color, num) do
    with {:ok, game} <- Validation.validate_mark(game, player_name, color, num),
         scorecard = game.players[player_name],
         {:ok, scorecard} <- Scorecard.mark(scorecard, color, num) do
      game = put_in(game.players[player_name], scorecard)
      game = put_in(game.turn_actions[player_name], {color, num})
      game = add_event(game, :mark, %{player: player_name, color: color, num: num})
      {:ok, maybe_advance(game)}
    end
  end

  def pass(%Game{} = game, player_name) do
    with {:ok, game} <- Validation.validate_pass(game, player_name) do
      cond do
        game.status == :white ->
          game = put_in(game.turn_actions[player_name], :pass)
          game = add_event(game, :pass, player_name)
          {:ok, maybe_advance(game)}

        game.turn_actions[player_name] == :pass ->
          {:ok, take_pass_penalty(game, player_name)}

        "pass on colored dice, but marked the white dice so it's ok" ->
          {:ok, maybe_advance(game)}
      end
    end
  end

  defp take_pass_penalty(game, player_name) do
    case Scorecard.pass(game.players[player_name]) do
      {:ok, scorecard} ->
        game = put_in(game.players[player_name], scorecard)
        game = add_event(game, :pass_with_penalty, player_name)
        maybe_advance(game)

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
      Enum.reduce(game.players, MapSet.new(), fn {_name, card}, acc ->
        acc = if 12 in card.red, do: MapSet.put(acc, :red), else: acc
        acc = if 12 in card.yellow, do: MapSet.put(acc, :yellow), else: acc
        acc = if 2 in card.blue, do: MapSet.put(acc, :blue), else: acc
        acc = if 2 in card.green, do: MapSet.put(acc, :green), else: acc
        acc
      end)

    # if any new colors were locked, add that to our event history
    game =
      case locked_colors |> MapSet.difference(MapSet.new(game.locked_colors)) |> MapSet.to_list() do
        [] -> game
        colors -> Enum.reduce(colors, game, &add_event(&2, :color_locked, &1))
      end

    game = %{game | locked_colors: MapSet.to_list(locked_colors)}
    pass_limit_hit = Enum.any?(game.players, fn {_, card} -> card.pass_count >= @pass_limit end)

    cond do
      pass_limit_hit || Enum.count(game.locked_colors) >= @locked_color_limit ->
        add_event(%{game | status: :game_over}, :status_changed, :game_over)

      game.status == :white ->
        add_event(%{game | status: :colors}, :status_changed, :colors)

      true ->
        add_event(%{game | status: :awaiting_roll}, :status_changed, :awaiting_roll)
    end
  end

  def roll(%{turn_order: [active_player | rest]} = game, name) do
    if game.status == :awaiting_roll && active_player == name do
      dice = Map.drop(Dice.roll(), game.locked_colors)

      {:ok,
       game
       |> Map.put(:dice, dice)
       |> Map.put(:turn_order, rest ++ [name])
       |> Map.put(:turn_actions, game.players |> Map.keys() |> Map.new(&{&1, :awaiting_choice}))
       |> add_event(:roll, %{player: name, dice: dice})
       |> Map.put(:status, :white)}
    else
      {:error, :not_players_turn_to_roll}
    end
  end

  defp add_event(%Game{} = game, event_name, event_data) do
    %{game | event_history: [{event_name, event_data} | game.event_history]}
  end
end
