# Copyright (C) 2014 paul@marrington.net, see GPL for license
files = require "files"

module.exports = (exchange, next) ->
  match = exchange.request.filename.match /(.*\.)css$/
  return next() if not match
  name = match[1]
  
  if exchange.request.url.exists
    exchange.respond.set_mime_type 'css'
    exchange.respond.static_file()
    return next()
  
  exts = exchange.environment.driver_alternates.css[0..-1]
  do find = ->
    if exts.length is 0
      return exchange.respond.error(
        "No #{exchange.request.filename}", 404)
    ext = exts.pop()
    files.find name + ext, (name) ->
      if name
        exchange.request.filename = name
        return require("drivers/#{ext}")(exchange, next)
      find()