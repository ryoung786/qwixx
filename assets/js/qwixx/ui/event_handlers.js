export function game_started(_data, _game, _new_game) {
  console.log("processed game_started");
}
export function player_added(name, _game, new_game) {
  sendEvent("js:player-added", { name: name, turn_order: new_game.turn_order });
}

export function player_removed(name, _game, _new_game) {
  sendEvent("js:player-removed", { name: name });
}

export function color_locked(color, _game, _new_game) {
  sendEvent("js:color-locked", { color: color });
}

export function mark(data, _game, new_game) {
  if (data.player == activePlayer()) {
    query = `.scorecard[data-player='${data.player}'] [data-color='${data.color}'] [data-num='${data.num}']`;
    add_tpl(query, "tpl-mark");
    if (data.lock) {
      query = `.scorecard[data-player='${data.player}'] [data-color='${data.color}'] [data-lock]`;
      add_tpl(query, "tpl-mark");
    }
    updateScore(data.player, new_game.players[data.player].score.total);
  }

  sendEvent("js:turn-taken", { action: "mark", player_name: data.player });
}

export function pass(player_name, _game, _new_game) {
  console.log("processed pass", player_name);
  sendEvent("js:turn-taken", { action: "pass", player_name: player_name });
}

export function pass_with_penalty(player_name, _game, new_game) {
  const active_player = activePlayer();

  // mark one of the pass section boxes
  if (player_name == active_player) {
    query = `.scorecard[data-player='${active_player}'] .pass_block[data-marked='0']`;
    add_tpl(query, "tpl-pass");
    document.querySelector(query).setAttribute("data-marked", 1);
  }
  updateScore(player_name, new_game.players[player_name].score.total);
}

export function roll(data, _game, _new_game) {
  sendEvent("js:roll", { dice: data.dice });
}

export function status_changed(new_status, _game, new_game) {
  if (new_status == "colors") {
    sendEvent("js:highlight-dice", "colors");
    sendEvent("js:status-changed", "colors");
  }
  if (new_status == "awaiting_roll") {
    sendEvent("js:set-player-turn", { name: new_game.turn_order[0] });
  }
  if (new_status == "game_over") {
    sendEvent("js:game-over", { game: new_game });
  }
}

function sendEvent(name, detail) {
  let event = new CustomEvent(name, { detail: detail });
  document.dispatchEvent(event);
}

function add_tpl(parent_query, tpl_id) {
  let parent = document.querySelector(parent_query);
  if (parent) {
    const template = document.getElementById(tpl_id);
    const clone = template.content.cloneNode(true);
    parent.appendChild(clone);
  }
}

export function activePlayer() {
  return document
    .querySelector("[data-active-player]")
    .getAttribute("data-active-player");
}

function updateScore(player_name, new_score) {
  if (player_name == activePlayer()) {
    query = `.scorecard[data-player='${player_name}'] .points`;
    document.querySelector(query).innerText = new_score;
  }
}
