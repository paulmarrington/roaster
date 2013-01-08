# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
driver = require 'http/driver'; fs = require 'file-system', step = require 'step'

# called by depends.coffee from the client. It is expecting a script that
# compiles to java-script. It wraps the resultint code in a function as
# expected by the server before sending it back using the original reply
# mechanism
module.exports = (exchange) ->
  fs.find exchange.request.url.query.url, (url) ->
    exchange.request.filename = url
    exchange.domain = 'client'

    next_reply = exchange.reply
    exchange.reply = (exchange) ->
      step(
        -> fs.readFile exchange.request.filename, this
        (error, js) ->
          throw error if error
          js = """

            #{exchange.request.url.query.global_var}=function(module){
              #{js}
            }

          """
          exchange.request.filename += '.depends.js'
          fs.writeFile exchange.request.filename, js, this
        (error) ->
          throw error if error
          next_reply exchange
      )
    driver(url)(exchange)
