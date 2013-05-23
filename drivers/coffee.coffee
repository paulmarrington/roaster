# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see GPL for license

# Coffee-script files can be sent to the browser to run, run on the server
# or spawned off to a separate process. These domains can be specified in
# more than one way:

# * The path a script is on (i.e. /client/ in the path somewhere)
# * file name extension (myfile.client.coffee)
# * explicit in a wrapping script setting exchange.domain
coffee = require 'morph/coffee'

module.exports = (exchange, next) ->
  exchange.respond.morph coffee, next
