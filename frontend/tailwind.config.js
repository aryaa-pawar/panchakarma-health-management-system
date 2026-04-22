export default {
  content: ["./index.html", "./src/**/*.{js,jsx}"],
  theme: {
    extend: {
      colors: {
        brand: {
          sand: "#f5ead7",
          clay: "#ba6b34",
          forest: "#1f4d3d",
          leaf: "#7ca982",
          ink: "#101828"
        }
      },
      fontFamily: {
        display: ["Georgia", "serif"],
        body: ["Trebuchet MS", "sans-serif"]
      },
      boxShadow: {
        glow: "0 20px 50px rgba(16, 24, 40, 0.22)"
      }
    }
  },
  plugins: []
};
