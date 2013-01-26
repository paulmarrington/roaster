# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
driver = require 'http/driver'; fs = require 'file-system', step = require 'step'

# called by depends.coffee from the client. It is expecting a script that
# compiles to java-script. It wraps the resultint code in a function as
# expected by the server before sending it back using the original reply
# mechanism
module.exports = (exchange) ->
  # fine the input file from the list of bases
  url = exchange.request.url.pathname.replace '.depends', ''

  fs.find url, (url) ->
    exchange.request.filename = url

    # wrap the reply so we can send an enclosing function
    exchange.reply = ->
      input = fs.createReadStream(exchange.request.filename)
      input.pause() # if we don't pause it disappears while writing header
      exchange.request.filename += '.depends.js'
      output = fs.createWriteStream(exchange.request.filename)

      step(
        -> # Step 1: write the global function definition
          @throw_errors = true
          @drain output, "#{exchange.request.url.query.global_var}=function(module){"
        -> # Step 2: write the code in the raw javascript file
          @pipe input, output
          input.resume()  # start pumping through the pipe
        -> # step 3: closing brace for the function
          @drain output, ";}"
        -> # Step 4: send it back to the browser
          respond.static exchange
      )

    # kick it all off as if it were directly in the server loop
    driver(url)(exchange)
