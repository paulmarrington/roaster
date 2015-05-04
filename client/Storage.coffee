# Copyright (C) 2015 paul@marrington.net, see /GPL for license

module.exports = class Storage
  constructor: (@name, @key, @opts = {}) ->
    @name = @key+count++ if not @name
    @key = "#{@key}::#{@name.replace(/[\.\/]+/g, '_')}"
    @value = localStorage[@key]
    try @value = JSON.parse(@value)
    catch then @value = @opts.default ? {}
    
  update: (values) ->
    @value[k] = v for k,v of values
    @save()
      
  save: ->
    localStorage[@key] = JSON.stringify @value

count = 0
