# Copyright (C) 2014 paul@marrington.net, see /GPL for license
processes = require 'processes'; npm = require 'npm'
dirs = require 'dirs'

class Phantom
  constructor: (url, loaded) ->
    npm 'phantomjs', (@error, phantomjs) ->
      startup = dirs.node 'boot/phantom-init.js'
      @proc = processes(phantomjs.path).
        spawn startup, url, (err) =>
          console.log err if err
          @onClose?()
      loaded()
  onClose: ->
      
module.exports = Phantom
