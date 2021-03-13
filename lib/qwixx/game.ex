defmodule Qwixx.Game do
  alias Qwixx.{Game, Scorecard, Player, Dice, Validation}

  defstruct players: %{},
            turn_order: [],
            status: :awaiting_start,
            dice: %Dice{},
            turn_actions: %{}

  @pass_limit 4
  @locked_color_limit 2

  def add_player(%Game{} = game, name) do
    if name not in Map.keys(game.players) do
      players = Map.put(game.players, name, %Player{name: name})
      added_to_end = game.turn_order ++ [name]
      %{game | players: players, turn_order: added_to_end}
    else
      {:error, :player_name_taken}
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

  defp roll(%Game{} = game), do: %{game | dice: Dice.roll(game)}

  def mark(%Game{} = game, player_name, color, num) do
    with {:ok, game} <- Validation.validate_mark(game, player_name, color, num),
         player <- game.players[player_name],
         {:ok, player} <- Player.mark(player, color, num) do
      game = put_in(game.players[player.name], player)
      game = put_in(game.turn_actions[player.name], {color, num})
      {:ok, maybe_advance(game)}
    else
      {:error, msg} -> {:error, msg}
    end
  end

  def pass(%Game{} = game, player_name) do
    with {:ok, game} <- Validation.validate_pass(game, player_name),
         player <- game.players[player_name] do
      cond do
        game.status == :white ->
          pass_on_white_dice(game, player)

        game.turn_actions[player_name] == :pass ->
          take_pass_penalty(game, player)

        "pass on colored dice, but marked the white dice so it's ok" ->
          {:ok, maybe_advance(game)}
      end
    else
      {:error, msg} -> {:error, msg}
    end
  end

  defp pass_on_white_dice(game, player) do
    game = put_in(game.turn_actions[player.name], :pass)
    {:ok, maybe_advance(game)}
  end

  defp take_pass_penalty(game, player) do
    with {:ok, player} <- Player.pass(player) do
      game = put_in(game.players[player.name], player)
      {:ok, maybe_advance(game)}
    else
      {:error, msg} -> {:error, msg}
    end
  end

  defp maybe_advance(%Game{} = game) do
    everyone_has_made_choice =
      game.turn_actions
      |> Enum.all?(fn {_name, action} -> action != :awaiting_choice end)

    if everyone_has_made_choice, do: advance(game), else: game
  end

  defp advance(%Game{} = game) do
    game = game |> enforce_locks()

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

  def active_player_name(%Game{turn_order: [player_name | _]}), do: player_name

  def scores(%Game{players: players}) do
    players
    |> Enum.map(fn {name, p} ->
      {name, Player.score(p)}
    end)
    |> Map.new()
  end
end
