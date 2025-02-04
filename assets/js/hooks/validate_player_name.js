export default {
  mounted() {
    const name = this.el.querySelector("input").getAttribute("value");
    this.handleEvent("validate", (_) =>
      this.pushEvent("validate", { name: name }),
    );
  },
};
