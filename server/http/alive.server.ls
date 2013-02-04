# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

# just don't return - so client can tell if server dies
module.exports = (exchange) ->
  setTimeout (-> exchange.response.end()), 120000
