# Copyright (C) 2013 paul@marrington.net, see GPL for license

module.exports =
  csv:
    split: (strings...) ->
      split = []
      split.push string.split(',')... for string in strings
      return split
      
  from_map: (map) ->
    return ("#{key}: #{value}" for key, value of map).join(',  ')

String::starts_with = (start) ->
  return false if not start or start.length > @length
  return @[0...start.length] is start

String::ends_with = (ending) ->
  return false if not ending or ending.length > @length
  return @[(@length - ending.length)..] is ending

String::regex_index_of = (regex, start = 0) ->
  index_of = @substring(start).search(regex)
  return if index_of is -1 then -1 else index_of + start

String::unescape = ->
  return @replace(/&gt;/g, '>').replace(/&lt;/g, '<').
    replace(/&quot;/g, '"').replace(/&#0?39;/g, "'").
    replace(/&x2F;/g, '/').replace(/&amp;/g, '&').
    replace(/&nbsp;/g, ' ')
