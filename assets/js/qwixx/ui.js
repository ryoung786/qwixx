import { animate } from "motion";
import Game from "./game";
let event_index = 0;
let game = new Game();

function process(event, data, new_game) {
  console.log("processing event", [event, data, new_game]);

  if (game.status == "awaiting_start") {
    if (event == "player_added") {
      // Add player animation
      console.log("player added event processed", data);
    } else if (event == "player_removed") {
      // Remove player animation
      console.log("player removed event processed", data);
    } else if (event == "status_changed" && data == "white") {
      // Game started! animation
      // roll_dice(game.dice);
      // highlight_dice("white");
    }
  } else {
    if (event == "status_changed" && data == "colors") {
      highlight_dice("colors");
    }

    if (event == "status_changed" && data == "white") {
      roll_dice(game.dice, new_game.dice);
      highlight_dice("white");
    }

    if (event == "mark") {
      mark(data.player, data.color, data.num);
    }

    if (event == "pass") {
      // TODO
      console.log("PASS", data);
    }
  }
}

function mark(player, color, num) {
  let div = document.querySelector(
    `.scorecard[data-player='${player}'] [data-color='${color}'] [data-num='${num}']`,
  );
  const template = document.getElementById("tpl-mark");
  const clone = template.content.cloneNode(true);
  div.appendChild(clone);
}

function highlight_dice(group) {
  white = document.querySelector(`[data-dice='white']`);
  colors = document.querySelector(`[data-dice='colors']`);

  if (group == "colors") {
    white.classList.remove("border-b-2", "border-pink-400");
    colors.classList.add("border-b-2", "border-pink-400");
  } else {
    white.classList.add("border-b-2", "border-pink-400");
    colors.classList.remove("border-b-2", "border-pink-400");
  }
}

function roll_dice(old_dice, new_dice) {
  let dice_el = document.getElementById("dice");
  const template = document.getElementById("tpl-roll");
  const clone = template.content.cloneNode(true);
  dice_el.appendChild(clone);
  let anim = document.getElementById("rolling-animation");
  const sequence = [
    [anim, { opacity: 1 }],
    [anim, { opacity: 1 }, { duration: 2.0 }],
    [anim, { opacity: 0 }],
  ];

  setTimeout(() => {
    toggle_dice(dice_el, "#w1 span", old_dice?.white[0], new_dice?.white[0]);
    toggle_dice(dice_el, "#w2 span", old_dice?.white[1], new_dice?.white[1]);
    toggle_dice(dice_el, "#red span", old_dice?.red, new_dice?.red);
    toggle_dice(dice_el, "#yellow span", old_dice?.yellow, new_dice?.yellow);
    toggle_dice(dice_el, "#green span", old_dice?.green, new_dice?.green);
    toggle_dice(dice_el, "#blue span", old_dice?.blue, new_dice?.blue);
  }, 1000);

  animate(sequence).then(() => {
    dice_el.removeChild(anim);
  });
}
function toggle_dice(el, query, old_n, new_n) {
  el.querySelector(query).classList?.remove(`lucide-dice-${old_n}`);
  el.querySelector(query).classList?.add(`lucide-dice-${new_n}`);
}

export default {
  handle_event: function (event) {
    let g = Game.createFromObj(event.detail);
    console.log("handling event. game:", g);
    console.log("handling event. index:", event_index);

    g.event_history
      .slice(0, g.event_history.length - event_index)
      .reverse()
      .forEach(([e, data]) => {
        process(e, data, g);
        event_index++;
      });

    game = g;
  },
};
