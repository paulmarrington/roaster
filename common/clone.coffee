# Copyright (C) 2014 paul@marrington.net, see /GPL license

module.exports =
  shallow: (from...) ->
    to = {}
    to[k] = v for k, v of f for f in from
