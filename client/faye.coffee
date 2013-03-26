# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license

# Return a faye client - loading and creating as necessary
client = null

module.exports = (next) ->
  steps(
    -> @requires '/faye/client.js'            # load faye library
    -> client = new Faye.Client '/faye'       # create a client instance
    -> module.exports = (next) -> next(client)# next call returns singleton
    -> next(client)                           # callback for this first time
    )
