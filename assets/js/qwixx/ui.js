import { animate } from "motion";
import Game from "./game";
import * as handlers from "./ui/event_handlers";

let event_index = 0;
let game = new Game();

export function initGame(g) {
  game = Game.createFromObj(g);
  event_index = game.event_history.length;
}

export function handleEvent(event) {
  const new_game = Game.createFromObj(event.detail);
  console.log("handling event. game:", new_game);
  console.log("handling event. index:", event_index);

  new_game.event_history
    .slice(0, new_game.event_history.length - event_index)
    .reverse()
    .forEach(([e, data]) => {
      handlers[e] && handlers[e](data, game, new_game);
      event_index++;
    });

  game = new_game;
}

/**
 * Slides a black screen from right to left, then redirects to `path`
 * once the animation is completed
 */
export function pageTransition(path) {
  animate(
    "#page-transition",
    { x: -(window.innerWidth + 40) },
    { duration: 0.5 },
  ).then(() => {
    location.assign(path);
  });

  return false;
}

export function roll() {
  if (game.status == "awaiting_start") window.dispatchToLV("start-game", null);
  window.dispatchToLV("roll", null);
}
