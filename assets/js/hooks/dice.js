import { stagger, animate } from "motion";
import { activePlayer } from "../qwixx/ui/event_handlers";

function animateShowRollButton(btn) {
  animate(btn, { rotate: 0, opacity: 0, x: "1rem" }, { duration: 0 });
  btn.classList.remove("hidden");
  animate(btn, { opacity: 1, x: 0 }).then(() => {
    btn.classList.add("animate-pulse");
  });
}
function animateHideRollButton(btn) {
  btn.classList.remove("hidden");
  animate(btn, { opacity: 0, x: "1rem" }).then(() => {
    btn.classList.add("hidden");
  });
}

function highlightDice(el, group) {
  white = el.querySelector(`[data-dice='white']`);
  colors = el.querySelector(`[data-dice='colors']`);
  white.removeAttribute("data-highlight");
  colors.removeAttribute("data-highlight");

  group == "colors" && colors.setAttribute("data-highlight", true);
  group == "white" && white.setAttribute("data-highlight", true);
}

function animateRoll(dice_el) {
  let dice_icons = dice_el.querySelectorAll("#dice [data-dice-icon]");
  let btn = dice_el.querySelector("button");

  btn.classList.remove("animate-pulse");

  animate([
    [
      btn,
      { rotate: -90 },
      { type: "spring", bounce: 0.6, visualDuration: 0.2 },
    ],
    [
      dice_icons,
      { opacity: 1, y: 0, x: dice_el.clientWidth / 2, rotate: 540 },
      { duration: 0, at: 0 },
    ],
    [
      dice_icons,
      { x: 0, rotate: 0 },
      {
        delay: stagger(0.04),
        type: "spring",
        visualDuration: 0.3,
        bounce: 0.4,
      },
    ],
  ]).then(() => {
    animateHideRollButton(btn);
    highlightDice(dice_el, "white");
  });
}

export default {
  mounted() {
    document.addEventListener("js:set-player-turn", (e) =>
      this.setPlayerTurn(e.detail.name),
    );
    document.addEventListener("js:roll", (e) => this.roll(e.detail.dice));

    document.addEventListener("js:highlight-dice", (e) => {
      highlightDice(this.el, e.detail);
    });

    document.addEventListener("js:color-locked", (e) =>
      this.removeDice(e.detail.color),
    );

    this.el.querySelector("button").addEventListener("click", (ev) => {
      ev.preventDefault();
      window.dispatchToLV("roll", null);
    });
  },

  setPlayerTurn(name) {
    let dice_icons = this.el.querySelectorAll("#dice [data-dice-icon]");
    animate(dice_icons, { opacity: 0, y: "1rem" }, { duration: 0.1 });
    highlightDice(this.el, null);

    let btn = this.el.querySelector("button");
    name == activePlayer()
      ? animateShowRollButton(btn)
      : animateHideRollButton(btn);
  },

  roll(new_dice) {
    this.toggleDice("#w1 span", new_dice?.white[0]);
    this.toggleDice("#w2 span", new_dice?.white[1]);
    this.toggleDice("#red span", new_dice?.red);
    this.toggleDice("#yellow span", new_dice?.yellow);
    this.toggleDice("#green span", new_dice?.green);
    this.toggleDice("#blue span", new_dice?.blue);

    animateRoll(this.el);
  },

  toggleDice(query, n) {
    el = this.el.querySelector(query);

    if (el) {
      old_class = Array.from(el.classList).find((e) =>
        e.startsWith("lucide-dice-"),
      );
      el.classList?.remove(old_class);
      el.classList?.add(`lucide-dice-${n}`);
    }
  },

  removeDice(color) {
    let die = this.el.querySelector(`#dice #${color}`);
    animate(die, { opacity: 0, y: "1rem" }, { duration: 0.1 }).then(() => {
      die.remove();
    });
  },
};
