defmodule Qwixx.GameTest do
  use ExUnit.Case

  alias Qwixx.Game
  alias Qwixx.Player
  alias Qwixx.Scorecard

  setup_all do
    %{
      game:
        %Game{}
        |> Game.add_player("a")
        |> Game.add_player("b")
        |> Game.start()
    }
  end

  describe "new game" do
    test "add and remove players" do
      game =
        %Game{}
        |> Game.add_player("a")
        |> Game.add_player("b")

      assert Enum.count(game.players) == 2

      game = Game.remove_player(game, "b")
      assert Enum.count(game.players) == 1
    end
  end

  describe "pass" do
    test "only penalize active player", %{game: game} do
      player = Game.active_player_name(game)
      other_player = if player == "a", do: "b", else: "a"

      assert {:ok, game} = Game.pass(game, player)
      assert {:ok, game} = Game.pass(game, other_player)
      assert {:error, :not_active_player} = Game.pass(game, other_player)
      assert {:ok, game} = Game.pass(game, player)

      assert %{^player => %{total: -5}, ^other_player => %{total: 0}} = Game.scores(game)
    end
  end

  describe "mark" do
    test "both can mark white", %{game: game} do
      game = put_in(game.dice.white, {5, 4})
      assert {:ok, game} = Game.mark(game, "a", :red, 9)
      assert {:ok, _game} = Game.mark(game, "b", :blue, 9)
    end

    test "advances to colors", %{game: game} do
      game = put_in(game.dice.white, {5, 4})
      {:ok, game} = Game.mark(game, "a", :red, 9)
      {:ok, game} = Game.mark(game, "b", :blue, 9)

      assert game.status == :colors
      assert %{"a" => %{total: 1}} = Game.scores(game)
    end

    test "changes turn after colors", %{game: game} do
      game = put_in(game.dice.white, {5, 4})
      {:ok, game} = Game.mark(game, "a", :red, 9)
      {:ok, game} = Game.mark(game, "b", :blue, 9)

      player = Game.active_player_name(game)
      other_player = if player == "a", do: "b", else: "a"
      c = game.dice.green

      assert {:error, :not_active_player} = Game.mark(game, other_player, :green, 5 + c)

      {:ok, game} = Game.mark(game, player, :green, 5 + c)

      assert game.status == :white
      assert %{^player => %{total: 2}, ^other_player => %{total: 1}} = Game.scores(game)
    end
  end

  describe "game over" do
    test "4 passes", %{game: game} do
      active_name = Game.active_player_name(game)
      other_player = if active_name == "a", do: "b", else: "a"

      # take 3 pass penalties
      player = game.players[active_name]
      {:ok, player} = Player.pass(player)
      {:ok, player} = Player.pass(player)
      {:ok, player} = Player.pass(player)
      game = put_in(game.players[player.name], player)

      # both pass on the white dice
      {:ok, game} = Game.pass(game, active_name)
      {:ok, game} = Game.pass(game, other_player)

      # 4th pass, brings score to -20 and ends game
      {:ok, game} = Game.pass(game, active_name)

      assert %{^active_name => %{total: -20}, ^other_player => %{total: 0}} = Game.scores(game)
      assert game.status == :game_over
    end

    test "2 locks by same player", %{game: game} do
      active_name = Game.active_player_name(game)
      other_player = if active_name == "a", do: "b", else: "a"

      # set dice to state we can get 2 12s
      game = %{game | dice: %{white: {6, 6}, yellow: 6}}

      player = %{
        game.players[active_name]
        | scorecard: %Scorecard{red: [2, 3, 4, 5, 6], yellow: [2, 3, 4, 5, 6]}
      }

      game = put_in(game.players[player.name], player)
      {:ok, game} = Game.mark(game, active_name, :red, 12)
      {:ok, game} = Game.pass(game, other_player)
      {:ok, game} = Game.mark(game, active_name, :yellow, 12)
      assert %{^active_name => %{total: 56}, ^other_player => %{total: 0}} = Game.scores(game)
      assert game.status == :game_over
    end

    test "2 total locks", %{game: game} do
      active_name = Game.active_player_name(game)
      other_name = if active_name == "a", do: "b", else: "a"

      # set dice to state we can get 2 12s
      game = %{game | dice: %{white: {6, 6}, red: 6}}
      player1 = %{game.players[active_name] | scorecard: %Scorecard{red: [2, 3, 4, 5, 6]}}
      player2 = %{game.players[other_name] | scorecard: %Scorecard{yellow: [2, 3, 4, 5, 6]}}

      game = put_in(game.players[active_name], player1)
      game = put_in(game.players[other_name], player2)

      {:ok, game} = Game.mark(game, other_name, :yellow, 12)
      {:ok, game} = Game.pass(game, active_name)

      # now red and yellow are both locked and the game is over
      {:ok, game} = Game.mark(game, active_name, :red, 12)

      assert %{^active_name => %{total: 28}, ^other_name => %{total: 28}} = Game.scores(game)
      assert game.status == :game_over
    end
  end

  describe "dice get rolled" do
    test "on new turn", %{game: game} do
      # known bad values so we know they will change on roll
      game = put_in(game.dice.red, 99)
      {:ok, game} = Game.pass(game, "a")
      {:ok, game} = Game.pass(game, "b")

      player = Game.active_player_name(game)
      {:ok, game} = Game.pass(game, player)

      assert game.status == :white
      assert game.dice.red in 1..6
    end
  end
end
