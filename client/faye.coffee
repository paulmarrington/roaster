# Copyright (C) 2013 paul@marrington.net, see /GPL for license

# Return a faye client - loading and creating as necessary
client = null

module.exports = (next) -> queue ->
  return next(client) if client
  @requires '/faye/client.js?domain=client', ->
    next new Faye.Client '/faye'
    
queue.mixin faye: module.exports