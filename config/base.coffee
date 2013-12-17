# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
module.exports = (environment) ->
  environment.port = 9009
  environment.cors_whitelist = []

  environment.extensions = css:'css', less:'css', scss: 'css', styl: 'css'
