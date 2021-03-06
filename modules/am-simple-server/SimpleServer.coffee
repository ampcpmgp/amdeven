fs = require("fs")
http = require("http")
#
chokidar = require('chokidar')
mime = require('mime')
sio = require('socket.io')
glob = require("glob")
lodash = require("lodash")

module.exports = class SimpleServer
  #config
  livereloadJs:  __dirname + "/browser/livereload.js"
  livereloadPath: "/__livereload.js"
  webDir:  [
    "./"
  ]
  # TODO: watchパスと、テスト/本番用パスは整理したい。（その場にjsを出す方式ならその2点のみ）
  watchPath: glob.sync("./**/web/*.@(html|js)", {ignore: "./**/node_modules/**"})
  sioOption: {}
  #module
  #info
  reloadList: []
  start: (@httpPort = 8080, @wsPort = @httpPort) ->
    try
      path = "./modules/am-simple-server/browser/livereload.js"
      fs.statSync(path)
      @livereloadJs = path
    catch error
      0
    @app = http.createServer((req, res) => @httpServerAction(req, res))
    lastArg = arguments[arguments.length-1]
    listen = => @app.listen(@httpPort, lastArg if typeof lastArg is "function")
    # TODO: reload時に前プロセスが残りportエラーで引っかかったのを解消。よりスマートに
    setTimeout(listen, 0)
    @wsStart()
  _checkExistsFile: (file) ->
    webDir = if typeof @webDir isnt "object" then [@webDir] else @webDir
    for dir in webDir
      path = "#{dir}#{file}"
      return path if fs.existsSync(path) and fs.lstatSync(path).isFile()
    return false
  httpServerAction: (req, res) ->
    #initial
    url = req.url.replace(/\/{2,}/, "/").replace(/\?.*$/, "")
    if url[url.length-1] is "/" then url += "index.html"
    ###get file###
    path = @_checkExistsFile(url)
    if path
      data = fs.readFileSync(path)
      unless data.length
        setTimeout((=> @httpServerAction(req, res)), 500)
        return
      type = mime.lookup(path)
      res.writeHead(200, "Content-Type": type)
      if type is "text/html"
        data = data.toString("utf8") + "<script src='#{@livereloadPath}'></script>"
        data = Buffer.from(data)
      res.end(data)
    else if url is @livereloadPath
      data = fs.readFileSync(@livereloadJs)
      type = mime.lookup(@livereloadJs)
      res.writeHead(200, "Content-Type": type)
      res.end(data)
    else
      res.writeHead(404)
      res.end("404 - file not found")
    ###access log###
    if url[url.length-4..url.length-1] is "html"
      ip = req.connection.remoteAddress.replace(/.*[^\d](\d+\.\d+\.\d+\.\d+$)/, "$1")
      date = new Date().toLocaleTimeString()
      console.log "#{date} #{ip} #{path}"
  wsStart: =>
    server = if @wsPort is @httpPort then @app else @wsPort
    @websocket = sio(server, @sioOption)
    @websocket.on("connection", (socket) =>
      @reloadList.push(socket)
      socket.on("test", (msg) => console.log msg)
    )
    @wsEventReload()
  wsEventReload: =>
    chokidar.watch(@watchPath,
      persistent: true
      awaitWriteFinish:
        stabilityThreshold: 10
        pollInterval: 10
    ).on("change", (path, stat) =>
      curDate = Date.now()
      diff = curDate - @wsEventReload_prevDate
      @wsEventReload_prevDate = curDate
      if diff < 2000 then return
      setTimeout(() =>
        @checkReloadList()
        @sendReloadEvent(socket) for socket in @reloadList
      , 200)
    )
  sendReloadEvent: (socket) -> socket.emit("reload")
  sendCssReloadEvent: (socket,filepath) -> socket.emit("css reload", fs.readFileSync(filepath, {encoding:"utf-8"}))
  checkReloadList: =>
    arr = []
    for socket, i in @reloadList
      if socket.disconnected then arr.unshift(i)
    for num in arr
      @reloadList.splice(num, 1)
