# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
fs = require "file-system"

module.exports = (environment) ->
  require(fs.node('/config/base'))(environment)
