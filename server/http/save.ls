# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! 'file-system'; require! 'path'

# http://localhost:9009/server/save?file=/My_Project/usdlc/Development/index.html
# contents of the file is in the body of the request as a binary stream
module.exports = (exchange) ->
  name = path.join './'  exchange.request.url.pathname
  file = file-system.createWriteStream name
  exchange.request.on 'data', (data) -> file.write data
  exchange.request.on 'end', ->
    file.end!
    exchange.response.writeHead(200)
    exchange.response.end!
