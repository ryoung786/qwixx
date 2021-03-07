defmodule Qwixx.GameTest do
  use ExUnit.Case

  alias Qwixx.Game

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

  describe "mark" do
    setup do
      %{
        game:
          %Game{}
          |> Game.add_player("a")
          |> Game.add_player("b")
          |> Game.start()
      }
    end

    test "both can mark white", %{game: game} do
      {a, b} = game.dice.white
      assert {:ok, game} = Game.mark(game, "a", :red, a + b)
      assert {:ok, game} = Game.mark(game, "b", :blue, a + b)
    end

    test "advances to colors", %{game: game} do
      {a, b} = game.dice.white
      {:ok, game} = Game.mark(game, "a", :red, a + b)
      {:ok, game} = Game.mark(game, "b", :blue, a + b)

      assert game.status == :colors
      assert %{"a" => %{total: 1}} = Game.scores(game)
    end

    test "changes turn after colors", %{game: game} do
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
end
