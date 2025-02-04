// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";
import topbar from "../vendor/topbar";
import * as QwixxUI from "./qwixx/ui";

window.QwixxUI = QwixxUI;
import Hooks from "./hooks";

console.log(Hooks);
// let Hooks = {};
// Hooks.RelayHook = {
//   mounted() {
//     relay = this;
//     document.addEventListener("relay-event", (e) =>
//       relay.pushEvent(e.detail.event, e.detail.payload),
//     );
//   },
// };
// Hooks.ValidatePlayerNameHook = {
//   mounted() {
//     const name = this.el.querySelector("input").getAttribute("value");
//     this.handleEvent("validate", (_) =>
//       this.pushEvent("validate", { name: name }),
//     );
//   },
// };

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
});

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" });
window.addEventListener("phx:page-loading-start", (_info) => topbar.show(300));
window.addEventListener("phx:page-loading-stop", (_info) => topbar.hide());

// connect if there are any LiveViews on the page
liveSocket.connect();

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket;

// Allows to execute JS commands from the server
window.addEventListener("phx:js-exec", ({ detail }) => {
  document.querySelectorAll(detail.to).forEach((el) => {
    liveSocket.execJS(el, el.getAttribute(detail.attr));
  });
});

window.addEventListener("phx:init", (e) => {
  console.log("app.js init listener", e);
  QwixxUI.initGame(e.detail);
});

window.addEventListener("phx:game-events", (e) => {
  console.log("app.js event listener", e);
  QwixxUI.handleEvent(e);
});

// window.dispatchToLV = function (event, payload) {
//   let relay_event = new CustomEvent("relay-event", {
//     detail: { event: event, payload: payload },
//   });
//   document.dispatchEvent(relay_event);
// };

window.addEventListener("phx:copy", (event) => {
  let text = event.target.innerText; // Alternatively use an element or data tag!
  console.log("phx copy", event);
  navigator.clipboard.writeText(text).then(() => {
    console.log("All done!"); // Or a nice tooltip or something.
  });
});
