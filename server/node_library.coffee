# Copyright (C) 2013 paul@marrington.net, see GPL for license
fs = require 'fs'; Internet = require('internet')
dirs = require 'dirs'; steps = require 'steps'

joyent = "https://raw.github.com/joyent/node/master/lib"

module.exports =
  # load node built-in modules from github
  resolve_built_in: (module_name, on_resolve) ->
    library_path = 'ext/node_library'
    local = dirs.node(library_path, "#{module_name}.js")
    url = "#{joyent}/#{module_name}.js"
    download = new Internet().download

    steps(
      -> dirs.mkdirs library_path, @next
      -> fs.exists local, @next (exists) => @skip() if exists
      -> download.from(url).to local, @next (@error) ->
      -> on_resolve(local)
    )
