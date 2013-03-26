# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
module.exports = (environment) ->
  require('config/base')(environment)
  environment.steps_timeout_ms = 15000
