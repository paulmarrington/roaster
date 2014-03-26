# Copyright (C) 2013 paul@marrington.net, see /GPL for license

# Return a faye client - loading and creating as necessary
client = null

module.exports = (next) ->
  return next(client) if client
  roaster.script_loader '/faye/client.js', ->
    next client = new Faye.Client '/faye'