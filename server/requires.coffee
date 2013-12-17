# Copyright (C) 2013 paul@marrington.net, see /GPL for license
npm = require 'npm'; path = require 'path'

module.exports = (name, next) ->
  key = path.basename(name).replace /\W/g, '_'
  try next(null, require(name))
  catch error
    npm.check_for_missing_requirement name, error
    npm.load name, (error, module) ->
      return next(error) if error
      next(null, module)