# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
module.exports = (environment) ->
  require('config/base')(environment)
  environment.debug = true
  environment.steps_timeout_ms = 10000
  environment.maximum_browser_cache_age = 10000
