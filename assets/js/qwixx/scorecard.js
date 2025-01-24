export default class Scorecard {
  red = [];
  yellow = [];
  blue = [];
  green = [];
  pass_count = 0;

  mark(color, num) {
    switch (color) {
      case "red":
        this.red.push(num);
        break;
      case "yellow":
        this.yellow.push(num);
        break;
      case "blue":
        this.blue.push(num);
        break;
      case "green":
        this.green.push(num);
        break;
    }
  }

  pass() {
    this.pass_count++;
    return this;
  }

  lock_bonus(color, row) {
    n = color in ["red", "yellow"] ? 12 : 2;
    return n in row;
  }
}
