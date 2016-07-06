Server = require("./Server")
Funcs = require("./Funcs")

http = require("http")
https = require("https")
fs = require("fs")
Client = require('ftp')
readline = require("readline")

module.exports = class @NodeApp extends Funcs
  ### class ###
  Server: Server
  constructor: ->
    @server = new @Server()
  start: ->
    @server.start()
  ### library ###
  ftpDownloader: (user, pass, file, host, filepath) ->
    c = new Client()
    c.on "ready", ->
      c.get "#{file}", (err, stream) ->
        throw err if err
        stream.once "close", ->
          c.end()
        stream.pipe fs.createWriteStream(filepath)
    c.connect
      host: host
      user: user
      password: pass
  readlineFunc: (path, callback) ->
    rs = fs.ReadStream(path)
    rl = readline.createInterface({'input': rs, 'output': {}})
    rl.on("line", callback)
    rl.resume()
  ftpDownloaderFullpath: (url, filepath) ->
    name = url.replace(/.*\/\/([^:]+).*/, "$1")
    pass = url.replace(/.*\/\/[^:]+:([^@]+).*/, "$1")
    file = url.replace(/.*\/([^/]+$)/, "$1")
    host = url.replace(/.*@([^/]+).*/, "$1")
    @ftpDownloader(name, pass, file, host, filepath)
  downloader: (url, filepath) -> #http, httpsに対応
    file = fs.createWriteStream(filepath)
    protocol = if url.match(/^https/) then https else http
    request = protocol.get(url, (response) -> response.pipe(file))