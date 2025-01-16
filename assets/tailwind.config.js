// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")
const defaultTheme = require('tailwindcss/defaultTheme')
const fs = require("fs")
const path = require("path")

module.exports = {
  content: [
    "../deps/salad_ui/lib/**/*.ex",
    "./js/**/*.js",
    "../lib/qwixx_web.ex",
    "../lib/qwixx_web/**/*.*ex"
  ],

  safelist: [
    "lucide-dice-1", "lucide-dice-2", "lucide-dice-3",
    "lucide-dice-4", "lucide-dice-5", "lucide-dice-6"
  ],
  theme: {
    extend: {
      colors: require("./tailwind.colors.json"),
      fontFamily: {
        sans: ["Jost", "Inconsolata", ...defaultTheme.fontFamily.sans],
        cbyg: ["Covered By Your Grace"],
        gaegu: ["Gaegu"],
        landing: ["Fredoka"]
      },
    },
  },
  plugins: [
    require("@tailwindcss/typography"),
    require("tailwindcss-animate"),
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add rules
    // only when LiveView classes are applied, for example:
    //
    //     <div class="phx-click-loading:animate-ping">
    //
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),

    // Embeds Heroicons (https://heroicons.com) into your app.css bundle
    // See your `CoreComponents.icon/1` for more information.
    //
    plugin(function({matchComponents, theme}) {
      let iconsDir = path.join(__dirname, "../deps/heroicons/optimized")
      let values = {}
      let icons = [
        ["", "/24/outline"],
        ["-solid", "/24/solid"],
        ["-mini", "/20/solid"],
        ["-micro", "/16/solid"]
      ]
      icons.forEach(([suffix, dir]) => {
        fs.readdirSync(path.join(iconsDir, dir)).forEach(file => {
          let name = path.basename(file, ".svg") + suffix
          values[name] = {name, fullPath: path.join(iconsDir, dir, file)}
        })
      })
      matchComponents({
        "hero": ({name, fullPath}) => {
          let content = fs.readFileSync(fullPath).toString().replace(/\r?\n|\r/g, "")
          let size = theme("spacing.6")
          if (name.endsWith("-mini")) {
            size = theme("spacing.5")
          } else if (name.endsWith("-micro")) {
            size = theme("spacing.4")
          }
          return {
            [`--hero-${name}`]: `url('data:image/svg+xml;utf8,${content}')`,
            "-webkit-mask": `var(--hero-${name})`,
            "mask": `var(--hero-${name})`,
            "mask-repeat": "no-repeat",
            "background-color": "currentColor",
            "vertical-align": "middle",
            "display": "inline-block",
            "width": size,
            "height": size
          }
        }
      }, {values})
    }),
    // lucide icons
    plugin(function ({ matchComponents, theme }) {
      let iconsDir = path.join(__dirname, "../deps/lucide/icons")
      let values = {}
      fs.readdirSync(iconsDir).forEach((file) => {
        if (path.extname(file) != ".svg") return;

        let name = path.basename(file, ".svg");
        values[name] = { name, fullPath: path.join(iconsDir, file) };
      })
      matchComponents({
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
        }
      }, { values })
    })
  ]
}
