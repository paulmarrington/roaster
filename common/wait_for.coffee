# Copyright (C) 2013 paul@marrington.net, see /GPL for license

# Helper so that multiple paths can wait for a singleton
# long-running process to complete. Useful when downloading
# packages and modules from the Internet.
# See common/patch.coffee for an example.
class WaitForIt
  constructor: (long_running_action) ->
    @waiting = []
    long_running_action.call @, (args...) =>
      @get = (self, next) ->
        next.apply(self, args)
        return @waiting.length
      while @waiting.length
        next = @waiting.pop()
        self = @waiting.pop()
        next.apply(self, args)
  # get returns the number of items waiting - so caller can decide to give up
  get: (self, next) ->
    @waiting.push(self, next)
    return @waiting.length

module.exports = wait_for = (long_running_action) ->
  waiter = new WaitForIt long_running_action
  return (next) -> waiter.get @, next
