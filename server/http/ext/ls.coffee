# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

# Live-script files can be sent to the browser to run, run on the server
# or spawned off to a separate process. These domains can be specified in
# more than one way:

# * The path a script is on (i.e. /client/ in the path somewhere)
# * file name extension (myfile.client.coffee)
# * explicit in a wrapping script setting exchange.domain
liveScript_morph = require 'morph/live-script'
domain = require 'domain'

module.exports = (exchange) ->
  domain.set exchange
  exchange.reply liveScript_morph
