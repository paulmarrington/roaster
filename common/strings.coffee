# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

module.exports =
  csv:
    split: (strings...) ->
      split = []
      split.append string.split ',' for string in strings
      return split
      
  from_map: (map) ->
    return ("#{key}: #{value}" for key, value of map).join(',  ')

String::ends_with = (ending) ->
  return false if not ending or ending.length > @length
  return @[(@length - ending.length)..] is ending
