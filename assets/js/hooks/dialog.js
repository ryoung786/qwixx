import { animate } from "motion";

export default {
  mounted() {
    document.addEventListener("js:game-over", (_e) => this.show());
    document.addEventListener("js:show", (_e) => this.show());
    document.addEventListener("js:hide", (_e) => this.hide());
  },

  show() {
    this.el.classList.remove("hidden");
    bg = this.el.querySelector("[data-overlay]");
    bg.classList.remove("hidden");
    document.querySelector("body").classList.add("overflow-hidden");
    animate(bg, { opacity: 1 }, { duration: 0.2 });
  },

  hide() {
    bg = this.el.querySelector("[data-overlay]");

    animate(bg, { opacity: 0 }, { duration: 0.2 }).then(() => {
      this.el.classList.add("hidden");
      bg.classList.add("hidden");
      document.querySelector("body").classList.remove("overflow-hidden");
    });
  },
};
