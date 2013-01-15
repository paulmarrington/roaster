# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

module.exports = (error, next) ->
  depends.script_loader '/faye/client.js', ->
    next null, new Faye.Client '/faye'
