var babel = require("babel")
var exec = require("child_process").exec
var fs = require("fs")

export default class CompilerSrc {
  log(msg){
    try {
      process.send(msg)
    } catch (e) {
      console.log(msg)
    }
  }
  compile_es6(filepath) {
    babel.transformFile(filepath, { stage: 0 }, (e, result) => {
      if(e) return CompilerSrc.prototype.log(e.message)
      CompilerSrc.prototype.log(`compile ${filepath}`)
      fs.writeFile(filepath.replace(/([\\|\/])src([\\|\/])/, "$1lib$2").replace(/\.es6$/, ".js"), result.code)
    })
  }
  compile_coffee(filepath) {
    let output = filepath.replace(/([\\|\/])src([\\|\/])/, "$1lib$2").replace(/[^\\|\/]+.coffee$/, "")
    let command = `coffee  -o ${output} -c ${filepath}`
    exec(command, (e, stdout, stderr) => {
      if(e) return CompilerSrc.prototype.log(stderr.replace(/.*:([0-9]+:[0-9]+.*)/, "$1"))
      CompilerSrc.prototype.log(`compile ${filepath}`)
    })
  }
  compile_sass(filepath) {
    let command = `sass ${filepath} ${filepath.replace(/([\\|\/])src([\\|\/])/, "$1css$2").replace(/sass$/, 'css')}`
    try {
      exec(command, (e, stdout, stderr) => {
        if(e) return CompilerSrc.prototype.log(stderr)
        CompilerSrc.prototype.log(`compile ${filepath}`)
      })
    } catch (e) {
      CompilerSrc.prototype.log(e.message)
    }
  }
}

/*
CompilerSrc.prototype.compile_es6("./src/CompilerSrc.es6")
CompilerSrc.prototype.compile_coffee("./src/main.coffee")
CompilerSrc.prototype.compile_sass("./src/default.sass")
*/
