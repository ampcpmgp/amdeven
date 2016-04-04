escape = require("escape-html")
listTag = require("./src/list.tag")
testCases = []
html = ""

recursive = (key, value, depth) =>
  if typeof value is "object"
    recursive(key, "", depth)
    recursive(key2, value2, depth + 1) for key2, value2 of value
  else
    testCases.push({key, value, depth})

module.exports = (obj) =>
  recursive(key, value, 0)  for key, value of obj
  box = document.createElement("div")
  box.innerHTML = html
  document.querySelector("body").appendChild(box)
  riot.mount('list', {
    testCases
  })