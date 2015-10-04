fs = require("fs")
exec = require('child_process').exec
cmd = "coffee -cm ./ && "

# TODO: npm installとコンパイルを分ける
# TODO: am-compilerを外に出しコンパイラを通す(am-devenからコンパイル)
# TODO: フローはnpm install -> mix compiler, flagのみ可
addList = (err, files) ->
  cmd += "cd node_modules/#{file}/ && npm install && coffee -cm ./ && cd ../../ && " for file in files
  cmd += "exit"
  console.log cmd
  console.log "child process start"
  child = exec(cmd, initFin)
initFin = (error, stdout, stderr) ->
  return console.log error if error
  return console.log stderr if stderr
  console.log stdout
  console.log "ended"
fs.readdir("./node_modules/", addList)
