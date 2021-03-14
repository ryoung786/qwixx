defmodule Qwixx.GameTest do
  use ExUnit.Case

  alias Qwixx.{Game, Player}

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

      assert game.players |> Enum.count() == 2

      game = Game.remove_player(game, "b")
      assert game.players |> Enum.count() == 1
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
      {a, b} = game.dice.white
      assert {:ok, game} = Game.mark(game, "a", :red, a + b)
      assert {:ok, _game} = Game.mark(game, "b", :blue, a + b)
    end

    test "advances to colors", %{game: game} do
      game = put_in(game.dice.white, {5, 4})
      {a, b} = game.dice.white
      {:ok, game} = Game.mark(game, "a", :red, a + b)
      {:ok, game} = Game.mark(game, "b", :blue, a + b)

      assert game.status == :colors
      assert %{"a" => %{total: 1}} = Game.scores(game)
    end

    test "changes turn after colors", %{game: game} do
      game = put_in(game.dice.white, {5, 4})
      {a, b} = game.dice.white
      {:ok, game} = Game.mark(game, "a", :red, a + b)
      {:ok, game} = Game.mark(game, "b", :blue, a + b)

      player = Game.active_player_name(game)
      other_player = if player == "a", do: "b", else: "a"
      {c, _} = game.dice.green

      assert {:error, :not_active_player} = Game.mark(game, other_player, :green, a + c)

      {:ok, game} = Game.mark(game, player, :green, a + c)

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
      game = %{game | dice: %{white: {6, 6}, yellow: {6, 6}}}

      # set active player's scorecard to have
      # red 2,3,4,5 and yellow 2,3,4,5 marked
      player =
        game.players[active_name]
        |> Player.mark!(:red, 2)
        |> Player.mark!(:red, 3)
        |> Player.mark!(:red, 4)
        |> Player.mark!(:red, 5)
        |> Player.mark!(:red, 6)
        |> Player.mark!(:yellow, 2)
        |> Player.mark!(:yellow, 3)
        |> Player.mark!(:yellow, 4)
        |> Player.mark!(:yellow, 5)
        |> Player.mark!(:yellow, 6)

      game = put_in(game.players[player.name], player)

      {:ok, game} = Game.mark(game, active_name, :red, 12)
      assert %{locked: false} = game.players[other_player].scorecard.red
      {:ok, game} = Game.pass(game, other_player)

      assert %{locked: true} = game.players[other_player].scorecard.red

      # now red and yellow are both locked and the game is over
      {:ok, game} = Game.mark(game, active_name, :yellow, 12)

      assert %{^active_name => %{total: 56}, ^other_player => %{total: 0}} = Game.scores(game)
      assert game.status == :game_over
    end

    test "2 total locks", %{game: game} do
      active_name = Game.active_player_name(game)
      other_name = if active_name == "a", do: "b", else: "a"

      # set dice to state we can get 2 12s
      game = %{game | dice: %{white: {6, 6}, red: {6, 6}}}

      # set active player's scorecard to red 2,3,4,5
      # set other player's scorecard to yellow 2,3,4,5
      player1 =
        game.players[active_name]
        |> Player.mark!(:red, 2)
        |> Player.mark!(:red, 3)
        |> Player.mark!(:red, 4)
        |> Player.mark!(:red, 5)
        |> Player.mark!(:red, 6)

      player2 =
        game.players[other_name]
        |> Player.mark!(:yellow, 2)
        |> Player.mark!(:yellow, 3)
        |> Player.mark!(:yellow, 4)
        |> Player.mark!(:yellow, 5)
        |> Player.mark!(:yellow, 6)

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
      game = put_in(game.dice.red, {99, 99})
      {:ok, game} = Game.pass(game, "a")
      {:ok, game} = Game.pass(game, "b")

      player = Game.active_player_name(game)
      {:ok, game} = Game.pass(game, player)

      assert game.status == :white
      assert game.dice.red != {99, 99}
    end
  end
end
