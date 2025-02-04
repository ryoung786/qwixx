import { animate } from "motion";

export default {
  mounted() {
    self = this;

    console.log("abc");
    document.addEventListener("js:player-added", (e) => {
      console.log("foo");
      self.addPlayer(e.detail.name, e.detail.turn_order);
    });

    document.addEventListener("js:set-active-player", (e) =>
      self.setActivePlayer(e.detail.name),
    );
  },

  addPlayer(_name, turn_order) {
    console.log("what");
    const template = document.getElementById("tpl-sidebar-player");

    animate(this.el, { opacity: 0, x: "-1rem" }).then(() => {
      this.el.innerHTML = "";
      turn_order.forEach((name) => {
        let clone = template.content.cloneNode(true);
        let el = clone.querySelector("div");
        clone.querySelector("div > div").textContent = name;
        el.setAttribute("data-player-name", name);

        this.el.appendChild(clone);
      });

      animate(this.el, { opacity: 1, x: 0 });
      this.setActivePlayer(turn_order[0]);
    });
  },

  setActivePlayer(name) {
    let player_nodes = this.el.querySelectorAll("[data-player-name]");
    player_nodes.forEach((el) => {
      el.classList.add("inactive");
      el.classList.remove("active");
      if (el.dataset["playerName"] == name) {
        el.classList.remove("inactive");
        el.classList.add("active");
      }
    });
  },
};
