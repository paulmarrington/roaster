# Copyright (C) 2013 paul@marrington.net, see /GPL for license
npm = require 'npm'; path = require 'path'

module.exports = (modules..., next) ->
  do one = =>
    return next(null) if not modules.length
    name = modules.shift()
    key = path.basename(name).replace /\W/g, '_'
    try
      @[key] = require(name)
      one()
    catch error
      npm.check_for_missing_requirement name, error
      @restart_timer(300)
      npm.load name, (error, module) =>
        next(error) if error
        @[key] = module
        one()
