module.exports = {
  sass: {
    files: ["scss/**/*.{scss,sass}"],
    tasks: ["scsslint:all", "copy:source", "sass:compile"]
  },
  js: {
    files: ["js/**/*.js", "tests/**/*.js"],
    tasks: ["jshint:all", "copy:source", "requirejs:compile", "test:js"]
  },
  images: {
    files: ["assets/**/*"],
    tasks: ["copy:assets"]
  }
}