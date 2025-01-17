import Scorecard from "./scorecard";

const pass_limit = 4;
const locked_color_limit = 2;

export default class Game {
  players = {};
  turn_order = [];
  status = "awaiting_start";
  dice = {};
  locked_colors = [];
  turn_actions = {};
  event_history = [];

  static createFromObj(obj) {
    let game = new Game();
    game.players = obj.players;
    game.turn_order = obj.turn_order;
    game.status = obj.status;
    game.dice = obj.dice;
    game.locked_colors = game.locked_colors;
    game.turn_actions = obj.turn_actions;
    game.event_history = obj.event_history;
    window.ggg = game;
    return game;
  }

  addPlayer(name) {
    this.players.set(name, new Scorecard());
    this;
  }

  removePlayer(name) {
    this.players.delete(name);
    this;
  }
}
