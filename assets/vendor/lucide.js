const fs = require("fs");
const path = require("path");

module.exports = function ({ matchComponents, theme }) {
  let iconsDir = path.join(__dirname, "../deps/lucide/icons");
  let values = {};
  fs.readdirSync(iconsDir).forEach((file) => {
    if (path.extname(file) != ".svg") return;

    let name = path.basename(file, ".svg");
    values[name] = { name, fullPath: path.join(iconsDir, file) };
  });
  matchComponents(
    {
      lucide: ({ name, fullPath }) => {
        let content = fs
          .readFileSync(fullPath)
          .toString()
          .replace(/\r?\n|\r/g, "")
          .replace(/stroke-width="2"/g, 'stroke-width="1.5"')
          .replace(/(?:width|height)="24"\s?/g, "");
        let size = theme("spacing.6");

        return {
          [`--lucide-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
          "-webkit-mask": `var(--lucide-${name})`,
          mask: `var(--lucide-${name})`,
          "mask-repeat": "no-repeat",
          "background-color": "currentColor",
          "vertical-align": "middle",
          display: "inline-block",
          width: size,
          height: size,
        };
      },
    },
    { values },
  );
};
