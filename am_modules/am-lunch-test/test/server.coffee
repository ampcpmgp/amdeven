fse = require("fs-extra")
LunchServer = require("../Server")
#pipeline for reload
require("raw!../browser/dev.js")

class TestLunch extends LunchServer
  webDir: "./am_modules/am-lunch-test/test/web/"
  watchPath: "./am_modules/am-lunch-test/test/web/test.js"
  patternFile:"./am_modules/am-lunch-test/test/web/case.cson"
  devJsPath: "#{process.cwd()}/am_modules/am-lunch-test/browser/dev.js"

class Test extends require("am-lunch-test/browser/Test")
  port: ([httpPort, wsPort]) =>
    TestLunch::start(httpPort, wsPort)

Test::start()
