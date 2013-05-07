# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
wait_for = require 'common/wait_for'; steps = require 'steps'

patch = null
diff = wait_for (next) ->
  steps(
    ->  @requires 'diff'
    ->  patch = @diff; next()
  )

module.exports =
  create: (filename, old_string, new_string, next) ->
    diff -> next patch.createPatch filename, old_string, new_string, '', ''
  apply: (old_string, diff_string, next) ->
    diff -> next patch.applyPatch old_string, diff_string
