# Copyright (C) 2014 paul@marrington.net, see /GPL license

module.exports = class Memory
  constructor: (@text) ->
  read: (read) -> read @text
  write: (text) -> @text = text
  flush: ->
