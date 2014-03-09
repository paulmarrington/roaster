# Copyright (C) 2013 paul@marrington.net, see /GPL license
processes = require 'processes'; dirs = require 'dirs'
npm = require 'scripts/npm'

module.exports = (args...) ->
  npm 'update'
