# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

# Helper so that multiple paths can wait for a singleton long-running process
# to complete. Useful when downloading packages and modules from the Internet.
# Used like:

# wait_for = require 'common/wait_for'
# package = wait_for (next) ->
#   steps(
#     -> dowload_package_from_internet_if_not_local()
#     -> make_package_available()
#     -> next()
#   )
# module.exports = (next) -> do_something(); package(next)

# Many processes can request this package and they will all be called when
# it becomes available. Afterwards it becomes a pass-through.

class WaitForIt
  constructor: (long_running_action) ->
    @waiting = waiting = []
    @context = {}
    long_running_action =>
      @get = (next) -> next.call(@context)
      next.call(@context) for next in waiting
  get: (next) -> @waiting.push next

module.exports = wait_for = (long_running_action) ->
  waiter = new WaitForIt long_running_action
  return (next) -> waiter.get next
