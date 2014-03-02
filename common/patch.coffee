# Copyright (C) 2013 paul@marrington.net, see /GPL license
wait_for = require 'wait_for'; npm = require 'npm'

preload = wait_for (next) ->
  npm 'diff', (error, patch) -> next(patch)

module.exports =
  create: (args...) -> preload (patch) ->
    module.exports.create = (name, oldst, newst, next) ->
      next patch.createPatch name, oldst, newst, '', ''
    module.exports.create(args...)
  apply: (args...) -> preload (patch) ->
    module.exports.apply = (oldst, diffst, next) ->
      next patch.applyPatch oldst, diffst
    module.exports.apply(args...)
