// See the Tailwind default theme values here:
// https://github.com/tailwindcss/tailwindcss/blob/master/stubs/defaultConfig.stub.js
const colors = require('tailwindcss/colors')
const defaultTheme = require('tailwindcss/defaultTheme');

/** @type {import('tailwindcss').Config */
module.exports = {
  darkMode: 'class',

  plugins: [
    require('@tailwindcss/aspect-ratio'),
    require('@tailwindcss/forms'),
    require('@tailwindcss/typography'),
  ],

  content: [
    './app/javascript/**/*.js',
    './app/views/**/*.erb',
    './public/*.html',
  ],
  theme: {
    extend: {
      fontSize: {
        xs: "11px",
        sm: "13px",
        base: "15px",
      },
    },
    container: {
      center: true,
      padding: {
        "DEFAULT": "1rem",
        "sm": "2rem",
        "md": "3rem",
        "lg": "4rem",
        "xl": "5rem",
        "2xl": "6rem",
      },
    },
    fontFamily: {
      body: ["DM Sans", "sans-serif"],
    },
  },
  darkMode: "class",
  safelist: [
    'bg-success/10', 'text-success',
    {
      pattern: /text-(gray|red|green|yellow|blue|purple|cyan)-(100|300|400|500)/ // LogColorsHelper uses custom tailwind colors
    }
  ]
}
