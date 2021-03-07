defmodule Qwixx.Game do
  alias Qwixx.{Game, Scorecard, Player, Dice}

  defstruct players: %{},
            turn_order: [],
            status: :awaiting_start,
            dice: %Dice{},
            turn_actions: %{}

  @pass_limit 4
  @locked_color_limit 2

  def add_player(%Game{} = game, name) do
    players = Map.put(game.players, name, %Player{name: name})
    %{game | players: players} |> shuffle_player_order()
  end

  def remove_player(%Game{} = game, name) do
    players = Map.delete(game.players, name)
    %{game | players: players} |> shuffle_player_order()
  end

  def restart_with_same_players(%Game{} = game), do: start(game)

  def start(%Game{players: players} = game) when map_size(players) > 0 do
    game
    |> Map.put(:status, :awaiting_start)
    |> reset_scorecards()
    |> shuffle_player_order()
    |> advance()
  end

  defp roll(%Game{} = game) do
    dice =
      %{
        red: {:rand.uniform(6), :rand.uniform(6)},
        yellow: {:rand.uniform(6), :rand.uniform(6)},
        blue: {:rand.uniform(6), :rand.uniform(6)},
        green: {:rand.uniform(6), :rand.uniform(6)},
        white: {:rand.uniform(6), :rand.uniform(6)}
      }
      |> Map.drop(locked_colors(game))

    %{game | dice: dice}
  end

  def mark(%Game{} = game, player_name, color, num) do
    with %Player{} = player <- Map.get(game.players, player_name) do
      game
      |> ensure_player_can_mark(player_name)
      |> do_mark(player, color, num)
      |> maybe_advance()
    else
      nil -> {:error, :player_does_not_exist}
    end
  end

  defp do_mark({:error, msg}, _player, _color, _num), do: {:error, msg}

  defp do_mark({:ok, game}, player, color, num) do
    case Player.mark(player, color, num) do
      {:ok, player} ->
        game = put_in(game.players[player.name], player)
        game = put_in(game.turn_actions[player.name], {color, num})
        {:ok, game}

      {:error, msg} ->
        {:error, msg}
    end
  end

  defp maybe_advance({:error, msg}), do: {:error, msg}

  defp maybe_advance({:ok, %Game{} = game}) do
    everyone_has_made_choice =
      game.turn_actions
      |> Enum.all?(fn {_name, action} -> action != :awaiting_choice end)

    game = if everyone_has_made_choice, do: advance(game), else: game
    {:ok, game}
  end

  defp advance(%Game{} = game) do
    game = game |> enforce_locks()

    if game_over?(game) do
      %{game | status: :game_over}
    else
      status =
        case game.status do
          :white -> :colors
          _ -> :white
        end

      game
      |> Map.put(:status, status)
      |> maybe_next_turn()
      |> roll()
    end
  end

  defp maybe_next_turn(%Game{status: :colors} = game), do: game

  defp maybe_next_turn(%Game{} = game) do
    [a | rest] = game.turn_order

    game
    |> Map.put(:turn_order, rest ++ [a])
    |> reset_turn_actions()
  end

  defp reset_turn_actions(%Game{} = game) do
    turn_actions =
      game.players
      |> Enum.map(fn {name, _} -> {name, :awaiting_choice} end)
      |> Map.new()

    %{game | turn_actions: turn_actions}
  end

  defp enforce_locks(%Game{} = game) do
    locked_colors = locked_colors(game)

    players =
      Enum.map(game.players, fn {name, player} ->
        player =
          Enum.reduce(locked_colors, player, fn color, player ->
            Player.lock_row(player, color)
          end)

        {name, player}
      end)

    %{game | players: Map.new(players)}
  end

  defp game_over?(%Game{players: players} = game) do
    num_locked_colors = locked_colors(game) |> Enum.count()

    any_players_hit_pass_limit =
      players
      |> Enum.any?(fn {_, %{scorecard: card}} -> card.pass_count >= @pass_limit end)

    any_players_hit_pass_limit or num_locked_colors >= @locked_color_limit
  end

  defp shuffle_player_order(%Game{players: players} = game) do
    names = Map.keys(players)
    %{game | turn_order: Enum.shuffle(names)}
  end

  def locked_colors(%Game{players: players}) when players == %{}, do: []

  def locked_colors(%Game{players: players}) do
    Enum.reduce(players, [], fn {_name, player}, acc ->
      locked_colors =
        Scorecard.rows(player.scorecard)
        |> Enum.filter(fn {_color, row} -> row.locked end)
        |> Enum.map(fn {color, _row} -> color end)

      acc ++ locked_colors
    end)
    |> Enum.uniq()
  end

  defp reset_scorecards(%Game{players: players} = game) do
    players =
      Enum.map(players, fn {name, _} ->
        {name, %Player{name: name}}
      end)
      |> Map.new()

    %{game | players: players}
  end

  defp ensure_player_can_mark(_game, nil), do: {:error, :player_does_not_exist}

  defp ensure_player_can_mark(%Game{} = game, player_name) when is_binary(player_name) do
    player = Map.get(game.players, player_name)
    ensure_player_can_mark(game, player)
  end

  defp ensure_player_can_mark(%Game{status: :white} = game, %Player{} = player) do
    case Map.get(game.turn_actions, player.name) do
      :awaiting_choice -> {:ok, game}
      _ -> {:error, :player_already_went}
    end
  end

  defp ensure_player_can_mark(%Game{status: :colors} = game, %Player{name: name}) do
    case active_player(game) do
      ^name -> {:ok, game}
      _ -> {:error, :not_active_player}
    end
  end

  def active_player(%Game{turn_order: [player | _]}), do: player

  def scores(%Game{players: players}) do
    players
    |> Enum.map(fn {name, p} ->
      {name, Player.score(p)}
    end)
    |> Map.new()
  end
end
