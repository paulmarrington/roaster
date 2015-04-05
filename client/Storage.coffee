# Copyright (C) 2015 paul@marrington.net, see /GPL for license

class Storage
  constructor: (@name, @key, @opts) ->
    return if not @name
    @key = "#{@name.replace(/[\.\/]/g, '_')}__#{@key}"
    @value = localStorage[@key]
    try @value = JSON.parse(@value)
    catch then @value = opts.default ? {}
      
  save: ->
    return if not @name
    localStorage[@key] = JSON.stringify @value

module.exports = Storage