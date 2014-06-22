# Copyright (C) 2014 paul@marrington.net, see /GPL license
npm = require 'npm'

module.exports = (args...) ->
  npm 'bower', (err, bower) ->
    bower.commands.install()