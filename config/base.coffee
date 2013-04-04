# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
module.exports = (environment) ->
  environment.port = 9009
  environment.cors_whitelist = []
  environment.steps_timeout_ms = 60000

  libraries = {}
