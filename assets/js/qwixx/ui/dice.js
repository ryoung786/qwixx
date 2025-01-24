import { animate } from "motion";

export function roll(new_dice) {
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
    toggleDice(dice_el, "#w1 span", new_dice?.white[0]);
    toggleDice(dice_el, "#w2 span", new_dice?.white[1]);
    toggleDice(dice_el, "#red span", new_dice?.red);
    toggleDice(dice_el, "#yellow span", new_dice?.yellow);
    toggleDice(dice_el, "#green span", new_dice?.green);
    toggleDice(dice_el, "#blue span", new_dice?.blue);
  }, 1000);

  animate(sequence).then(() => {
    dice_el.removeChild(anim);
  });
}

function toggleDice(el, query, n) {
  old_class = Array.from(el.querySelector(query).classList).find((e) =>
    e.startsWith("lucide-dice-"),
  );
  el.querySelector(query).classList?.remove(old_class);
  el.querySelector(query).classList?.add(`lucide-dice-${n}`);
}

export function highlightWhite() {
  highlightDice("white");
}

export function highlightColors() {
  highlightDice("colors");
}

function highlightDice(group) {
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
