Common = require("am-common")

http = require("http")
sio = require('socket.io')
mime = require('mime')
gaze = require("gaze")

module.exports = class Server extends Common
  #config
  proj_path: "contents/proj/web"
  #module
  #info
  reload_list: []
  start: (@http_port = @http_port, @ws_port = @ws_port)->
    @app = http.createServer((req, res) => @http_server_action(req, res))
    @ws_start()
  http_server_action: (req, res) ->
    #initial
    url = req.url.replace(/\/{2,}/, "/")
    params = @get_params url
    #modify
    url = url.replace(/\?.*$/, "")
    if url[url.length-1] is "/" then url += "index.html"
    ###get file###
    # set path
    path = "#{@proj_path}#{url}"
    # send data
    exists_flag = fs.existsSync(path)
    if exists_flag
      data = fs.readFileSync(path)
      type = mime.lookup path
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
  ws_start: ->
    if @ws_port is @http_port
      @websocket = sio(@app)
    else
      @websocket = sio(@ws_port)
    @app.listen(@http_port)
    @websocket.on("connection", (socket) =>
      socket.on("all",=>@reload_list.push(socket))
    )
    @ws_event_reload()
  ws_event_reload: ->
    me = @
    dir = [
      "#{@proj_path}/**/*.js"
      "#{@proj_path}/**/*.html"
    ]
    gaze(dir, (err, watcher) ->
      @on("changed", (filepath) =>
        me.check_reload_list()
        me.send_reload_event(socket) for socket in me.reload_list
      )
    )
    css_dir = [
      "#{@proj_path}**/*.css"
    ]
    gaze(css_dir, (err, watcher) ->
      @on("changed", (filepath) =>
        me.check_reload_list()
        me.send_css_reload_event(socket, filepath) for socket in me.reload_list
      )
    )
  send_reload_event: (socket) => socket.emit("reload")
  send_css_reload_event: (socket,filepath) => socket.emit("css reload", fs.readFileSync(filepath, {encoding:"utf-8"}))
  check_reload_list: =>
    arr = []
    for socket, i in @reload_list
      if socket.disconnected then arr.unshift(i)
    for num in arr
      @reload_list.splice(num, 1)
