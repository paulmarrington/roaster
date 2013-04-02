# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license
fs = require 'fs'; internet = require('internet')(); dirs = require 'dirs'
steps = require 'steps'
module.exports =
  # load node built-in modules from github
  resolve_built_in: (module_name, on_resolve) ->
    library_path = 'ext/node_library'
    local = fs.node(library_path, "#{module_name}.js")
    url = "https://raw.github.com/joyent/node/master/lib/#{module_name}.js"

    steps(
      -> dirs.mkdirs library_path, @next
      -> fs.exists local, @next (exists) => @steps.shift() if exists
      -> internet.download.from(url).to(local, @next)
      -> on_resolve(local)
      )
