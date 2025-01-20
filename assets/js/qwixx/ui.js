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
      console.log("Roll those dice", new_game.dice);
      highlight_dice("white");
    }
  } else {
    if (event == "status_changed" && data == "colors") {
      // Highlight color dice
      highlight_dice("colors");
    }

    if (event == "status_changed" && data == "white") {
      // Highlight color dice
      highlight_dice("white");
    }

    if (event == "mark") {
      // Mark DOM
      mark(data.player, data.color, data.num);
    }

    if (event == "pass") {
      // Mark DOM
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
