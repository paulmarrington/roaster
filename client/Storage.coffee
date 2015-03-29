# Copyright (C) 2015 paul@marrington.net, see /GPL for license

class Storage
  constructor: (@name, @key, defaults={}) ->
    return if not @name
    @key = "#{@name}__#{@key}"
    @value = localStorage[@key]
    try @value = JSON.parse(@value)
    catch then @value = defaults
      
  save: (value...) ->
    return if not @name
    switch value.length
      when 0 then value = @value
      when 1 then value = value[0]
    localStorage[@key] = JSON.stringify @value = value

module.exports = Storage