import { animate } from "motion";

export function game_started(_data, _game, _new_game) {
  console.log("processed game_started");
}
export function player_added(name, _game, new_game) {
  sendEvent("js:player-added", { name: name, turn_order: new_game.turn_order });
}

export function player_removed(name, _game, _new_game) {
  sendEvent("js:player-removed", { name: name });
}

export async function color_locked(color, _game, _new_game) {
  await animateLockAlert(color);
  await animateRemoveDice(color);
}

export async function mark(data, _game, new_game) {
  if (data.player == activePlayer()) {
    await animateMark(data.color, data.num);
    if (data.lock) await animateMark(data.color, "lock");
    updateScore(data.player, new_game.players[data.player].score.total);
  }
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

export async function status_changed(new_status, _game, new_game) {
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

function animateMark(color, val) {
  const cell = val == "lock" ? "[data-lock]" : `[data-num='${val}']`;
  const query = `.scorecard[data-player='${activePlayer()}'] [data-color='${color}'] ${cell}`;
  add_tpl(query, "tpl-mark");
  let mark_el = document.querySelector(`${query} [data-mark]`);
  mark_el.style = "opacity: 0";
  return animate(mark_el, { opacity: 1 });
}

async function animateLockAlert(color) {
  const SPRING = { type: "spring", bounce: 0.6, visualDuration: 0.2 };
  el = document.getElementById("color-locked-dialog");
  el.classList.remove("hidden");
  bg = el.querySelector("[data-overlay]");
  content = el.querySelector("[data-content]");
  content.setAttribute("data-color", color);
  content.querySelector("[data-text]").textContent = `${color} locked`;
  bg.classList.remove("hidden");
  document.querySelector("body").classList.add("overflow-hidden");
  await animate([
    [
      content,
      { opacity: 0, skewX: -6, x: "5rem", y: "-5rem" },
      { duration: 0 },
    ],
    [bg, { opacity: 1 }],
    [
      content,
      { opacity: 1, x: 0, y: 0 },
      { duration: 0.2, delay: 0.3, x: SPRING, y: SPRING },
    ],
    [bg, { opacity: 0 }, { delay: 2 }],
    [
      content,
      { opacity: 0, x: "-5rem", y: "5rem" },
      { at: "<", delay: 2, ease: "easeIn", duration: 0.2 },
    ],
  ]);

  el.classList.add("hidden");
  bg.classList.add("hidden");
  document.querySelector("body").classList.remove("overflow-hidden");
}

async function animateRemoveDice(color) {
  let die = document.querySelector(`#dice #${color}`);
  await animate(die, { opacity: 0, y: "1rem" }, { duration: 0.1 });
  die.remove();
}
