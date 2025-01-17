import { animate } from "motion";

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
};
