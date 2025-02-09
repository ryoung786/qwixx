import { stagger, animate } from "motion";

export function rollDice() {
  let dice_el = document.getElementById("dice");
  let dice_icons = document.querySelectorAll("#dice [data-dice-icon]");

  animate(dice_icons, { x: dice_el.clientWidth, rotate: 720 }, { duration: 0 });
  animate([
    [dice_icons, { x: dice_el.clientWidth / 2, rotate: 540 }, { duration: 0 }],
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
