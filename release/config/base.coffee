# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
dirs = require "dirs"

module.exports = (environment) ->
  require(dirs.node('/config/base'))(environment)
