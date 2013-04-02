# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license
fs = require 'fs'; internet = require 'internet'

module.exports =
  # load node built-in modules from github
  resolve_built_in = (module_name, on_resolve) ->
    local = fs.node('ext/node_library', module_name)
    fs.exists local, (exists) ->
      return on_resolve(local) if exists
      url = "https://raw.github.com/joyent/node/master/lib/#{module_name}.js"
      internet.download.from(url).to(local, -> on_resolve(local))
