import { animate } from "motion";

export default {
  mounted() {
    let { target } = this.el.dataset;
    let check = this.el.querySelector(".lucide-copy-check");
    let copy = this.el.querySelector(".lucide-copy");

    this.el.addEventListener("click", (ev) => {
      ev.preventDefault();
      let text = document.querySelector(target).innerText;
      navigator.clipboard.writeText(text).then(() => {
        animate([
          [check, { opacity: 1 }, { at: 0 }],
          [copy, { opacity: 0 }, { at: 0 }],
          [check, { opacity: 0 }, { at: 3 }],
          [copy, { opacity: 1 }, { at: 3 }],
        ]);
      });
    });
  },
};
