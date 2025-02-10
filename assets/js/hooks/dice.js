import { stagger, animate } from "motion";

function animateRoll(dice_el) {
  let dice_icons = dice_el.querySelectorAll("#dice [data-dice-icon]");

  animate([
    [
      dice_icons,
      { opacity: 1, y: 0, x: dice_el.clientWidth / 2, rotate: 540 },
      { duration: 0 },
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
  ]);
}

export default {
  mounted() {
    document.addEventListener("js:set-player-turn", (_e) => this.hideDice());
    document.addEventListener("js:roll", (e) => this.roll(e.detail.dice));

    document.addEventListener("js:highlight-dice", (e) =>
      this.highlightDice(e.detail),
    );

    this.el.querySelector("button").addEventListener("click", (ev) => {
      ev.preventDefault();
      window.dispatchToLV("roll", null);
    });
  },

  hideDice() {
    let dice_icons = this.el.querySelectorAll("#dice [data-dice-icon]");
    animate(dice_icons, { opacity: 0, y: "1rem" }, { duration: 0.1 });
    this.highlightDice(null);
  },

  roll(new_dice) {
    this.toggleDice("#w1 span", new_dice?.white[0]);
    this.toggleDice("#w2 span", new_dice?.white[1]);
    this.toggleDice("#red span", new_dice?.red);
    this.toggleDice("#yellow span", new_dice?.yellow);
    this.toggleDice("#green span", new_dice?.green);
    this.toggleDice("#blue span", new_dice?.blue);

    animateRoll(this.el);
    this.highlightWhite();
  },

  toggleDice(query, n) {
    old_class = Array.from(this.el.querySelector(query).classList).find((e) =>
      e.startsWith("lucide-dice-"),
    );
    this.el.querySelector(query).classList?.remove(old_class);
    this.el.querySelector(query).classList?.add(`lucide-dice-${n}`);
  },

  highlightWhite() {
    this.highlightDice("white");
  },

  highlightColors() {
    this.highlightDice("colors");
  },

  highlightDice(group) {
    white = this.el.querySelector(`[data-dice='white']`);
    colors = this.el.querySelector(`[data-dice='colors']`);

    if (group == "colors") {
      white.classList.remove("border-b-2", "border-pink-400");
      colors.classList.add("border-b-2", "border-pink-400");
    } else if (group == "white") {
      white.classList.add("border-b-2", "border-pink-400");
      colors.classList.remove("border-b-2", "border-pink-400");
    } else {
      white.classList.remove("border-b-2", "border-pink-400");
      colors.classList.remove("border-b-2", "border-pink-400");
    }
  },
};
