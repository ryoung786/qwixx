import { animate } from "motion";

const SPRING = { type: "spring", bounce: 0.6, visualDuration: 0.2 };

export default {
  mounted() {
    document.addEventListener("js:color-locked", (e) =>
      this.showHide(e.detail.color),
    );
    document.addEventListener("foo", (_e) => this.showHide("yellow"));
  },

  showHide(color) {
    this.el.classList.remove("hidden");
    bg = this.el.querySelector("[data-overlay]");
    content = this.el.querySelector("[data-content]");
    content.setAttribute("data-color", color);
    content.querySelector("[data-text]").textContent = `${color} locked`;
    bg.classList.remove("hidden");
    document.querySelector("body").classList.add("overflow-hidden");
    animate([
      [
        content,
        { opacity: 0, skewX: -6, x: "5rem", y: "-5rem" },
        { duration: 0 },
      ],
      [bg, { opacity: 1 }],
      [
        content,
        { opacity: 1, x: 0, y: 0 },
        { duration: 0.2, delay: 0.3, x: SPRING, y: SPRING },
      ],
      [bg, { opacity: 0 }, { delay: 2 }],
      [
        content,
        { opacity: 0, x: "-5rem", y: "5rem" },
        { at: "<", delay: 2, ease: "easeIn", duration: 0.2 },
      ],
    ]).then(() => {
      this.el.classList.add("hidden");
      bg.classList.add("hidden");
      document.querySelector("body").classList.remove("overflow-hidden");
    });
  },
};
