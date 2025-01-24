import { animate } from "motion";
import UI from "./qwixx/ui";

function pageTransition(path) {
  animate(
    "#page-transition",
    { x: -(window.innerWidth + 40) },
    { duration: 0.5 },
  ).then(() => {
    location.assign(path);
  });

  return false;
}

export default {
  pageTransition: pageTransition,
  UI: UI,
};
