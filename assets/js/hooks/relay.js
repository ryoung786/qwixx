// Allows the client to send an event to the live view server process

window.dispatchToLV = function (event, payload) {
  let relay_event = new CustomEvent("relay-event", {
    detail: { event: event, payload: payload },
  });
  document.dispatchEvent(relay_event);
};

export default {
  mounted() {
    relay = this;
    document.addEventListener("relay-event", (e) =>
      relay.pushEvent(e.detail.event, e.detail.payload),
    );
  },
};
