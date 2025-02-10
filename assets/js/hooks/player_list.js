import { animate } from "motion";

export default {
  mounted() {
    document.addEventListener("js:player-added", (e) => {
      this.addPlayer(e.detail.name, e.detail.turn_order);
    });
    document.addEventListener("js:player-removed", (e) => {
      this.removePlayer(e.detail.name);
    });

    document.addEventListener("js:set-player-turn", (e) =>
      this.setPlayerTurn(e.detail.name),
    );

    document.addEventListener("js:turn-taken", (e) =>
      this.turnTaken(e.detail.player_name),
    );

    document.addEventListener("js:status-changed", (e) => {
      e.detail == "colors" ? this.waitOnActivePlayer() : null;
    });
  },

  addPlayer(_name, turn_order) {
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
      this.setPlayerTurn(turn_order[0]);
    });
  },

  removePlayer(name) {
    let el = this.el.querySelector(`[data-player-name="${name}"]`);
    animate(el, { opacity: 0, x: "-1rem" }).then(() => el.remove());
  },

  setPlayerTurn(name) {
    let player_nodes = this.el.querySelectorAll("[data-player-name]");
    player_nodes.forEach((el) => {
      el.classList.add("inactive");
      el.classList.remove("active");
      if (el.dataset["playerName"] == name) {
        el.classList.remove("inactive");
        el.classList.add("active");
      }

      togglePlayerIcons(el, "clock");
    });
  },

  turnTaken(name) {
    let el = this.el.querySelector(`[data-player-name="${name}"]`);
    togglePlayerIcons(el, "check");
  },

  waitOnActivePlayer() {
    let active_el = this.el.querySelector(".active[data-player-name]");
    togglePlayerIcons(active_el, "clock");
  },
};

function togglePlayerIcons(el, to_display) {
  let clock = el.querySelector(".lucide-clock");
  let check = el.querySelector(".lucide-circle-check-big");
  const clazz = "opacity-0";

  if (to_display == "clock") {
    clock.classList.remove(clazz);
    check.classList.add(clazz);
  } else if (to_display == "check") {
    clock.classList.add(clazz);
    check.classList.remove(clazz);
  } else {
    clock.classList.add(clazz);
    check.classList.add(clazz);
  }
}
