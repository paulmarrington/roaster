# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license

# Return a faye client - loading and creating as necessary
client = null

module.exports = (next) ->
  return next(client) if client
  steps(
    -> @requires '/faye/client.js?domain=client' # load faye library
    -> client = new Faye.Client '/faye'       # create a client instance
    -> next(client)                           # callback for this first time
    )
