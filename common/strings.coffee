# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

module.exports =
  csv:
    split: (strings...) ->
      split = []
      split.append string.split ',' for string in strings
      return split