import { animate } from "motion";
import Game from "./game";
import * as handlers from "./ui/event_handlers";

let event_index = 0;
let game = new Game();

export function initGame(g) {
  game = Game.createFromObj(g);
  event_index = game.event_history.length;
}

export async function handleEvent(event) {
  const new_game = Game.createFromObj(event.detail);

  const events = new_game.event_history
    .slice(0, new_game.event_history.length - event_index)
    .reverse();

  for (const [e, data] of events) {
    handlers[e] && (await handlers[e](data, game, new_game));
    event_index++;
  }

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
