import * as Dice from "./dice";

export function game_started(_data, _game, _new_game) {
  console.log("processed game_started");
}
export function player_added(name, _game, _new_game) {
  console.log("processed player_added", name);
}

export function player_removed(name, _game, _new_game) {
  console.log("processed player_removed", name);
}

export function mark(data, _game, _new_game) {
  query = `.scorecard[data-player='${data.player}'] [data-color='${data.color}'] [data-num='${data.num}']`;
  add_tpl(query, "tpl-mark");
}

export function pass(player_name, _game, _new_game) {
  console.log("processed pass", player_name);
}

export function pass_with_penalty(player_name, _game, _new_game) {
  const active_player = activePlayer();
  if (player_name == active_player) {
    query = `.scorecard[data-player='${active_player}'] .pass_block[data-marked='0']`;
    add_tpl(query, "tpl-pass");
  }
}

export function roll(data, _game, _new_game) {
  Dice.roll(data.dice);
}

export function status_changed(new_status, _game, _new_game) {
  // if (game.status == "awaiting_start") return;

  if (new_status == "white") {
    // Dice.roll(new_game.dice);
    Dice.highlightWhite();
  } else if (new_status == "colors") {
    Dice.highlightColors();
  }
}

function add_tpl(parent_query, tpl_id) {
  let div = document.querySelector(parent_query);
  const template = document.getElementById(tpl_id);
  const clone = template.content.cloneNode(true);
  div.appendChild(clone);
}

function activePlayer() {
  return document
    .querySelector("[data-active-player]")
    .getAttribute("data-active-player");
}
