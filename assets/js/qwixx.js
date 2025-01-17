import { animate } from "motion";
import UI from "./qwixx/ui";

export default {
  pageTransition: (path) => {
    animate(
      "#page-transition",
      { x: -(window.innerWidth + 40) },
      { duration: 0.5 },
    ).then(() => {
      location.assign(path);
    });

    return false;
  },

  UI: UI,
};
