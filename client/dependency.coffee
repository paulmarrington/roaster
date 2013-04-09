# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

# Client side helper to load external libraries from the internet and
# then load files from them into the browser. Both processes are cached.
# Used like:

# jqueryUI = require('dependency')(
#   jquery: 'http://jqueryui.com/resources/download/jquery-ui-1.10.2.zip'
#   '/ext/jquery/jquery-1.9.1.js', '/ext/jquery/ui/jquery-ui.js'
#   )
# module.exports = (next) -> jqueryUI.get(next)

# The first time a package is needed it is downloaded. The first time
# a new browser session needs modules they are uploaded from roaster.
# modules can be css, js or any of the derived types such as coffee-script
# or less.

class loader
  constructor: (packages, libraries) ->
    @waiting = []
    steps(
      ->  @dependency packages
      ->  @libraries libraries
      ->  @get = (next) -> next()
      ->  next() for next in waiting
    )
  get: (next) -> @waiting.push next

module.exports = (packages, libraries...) -> new Loader packages, libraries
