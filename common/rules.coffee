# Copyright (C) 2013 paul@marrington.net, see GPL for license

# Given a list of matching regular expressions and action functions
# call the one that matches an input statement, passing any matching
# captures as parameters.
#
# Rules = require 'rules'
# rules = new Rules /rule (\d+): no poofdas/, (rn) -> console.log "Rule #{rn}"
# rules.add /[Tt]here is no rule (\d+)/, (rn) -> console.log "No #{rn}"
#
class Rules
  constructor: (@context = @) ->
    @patterns = []
  add: (patterns...) -> @patterns.push(patterns...); return @
  find: (statement) ->
    # Look for a matching statement, then return the action
    for pattern, index in @patterns by 2
      if matched = pattern.exec(statement)
        # matched = (match.toString() for match in matched)
        parameters = matched[1..] if matched.length > 1
        return [action = @patterns[index + 1], parameters]
    return null
  run: (statement) ->
    action = @find statement
    return false if not action
    try action[0].apply(@context, action[1]) catch err
      console.log action.toString()
      console.log err.stack if err.stack
      throw err
    return true
module.exports = Rules