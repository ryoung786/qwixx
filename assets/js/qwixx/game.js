import Scorecard from "./scorecard";

const pass_limit = 4;
const locked_color_limit = 2;

export default class Game {
  players = new Map();
  turn_order = [];
  status = "awaiting_start";
  locked_colors = [];
  turn_actions = new Map();
  event_history = [];

  addPlayer(name) {
    this.players.set(name, new Scorecard());
    this;
  }

  removePlayer(name) {
    this.players.delete(name);
    this;
  }
}
