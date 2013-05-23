# Copyright (C) 2012 Paul Marrington (paul@marrington.net), see GPL for license
fs = require 'fs'; path = require 'path'; dirs = require 'dirs'

# http://localhost:9009/server/save?file=/My_Project/usdlc/Development/index.html
# contents of the file is in the body of the request as a binary stream
module.exports = (exchange) ->
  file = fs.createWriteStream dirs.base exchange.request.query.filename
  file = fs.createWriteStream name
  exchange.request.on 'data', (data) -> file.write data
  exchange.request.on 'end', ->
    file.end()
    exchange.respond.json error : false
