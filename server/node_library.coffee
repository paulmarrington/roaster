# Copyright (C) 2013 paul@marrington.net, see GPL for license
fs = require 'fs'; Internet = require('internet')
dirs = require 'dirs'

joyent = "https://raw.github.com/joyent/node/master/lib"

module.exports =
  # load node built-in modules from github
  resolve_built_in: (module_name, on_resolve) ->
    library_path = 'ext/node_library'
    local = dirs.node(library_path, "#{module_name}.js")
    url = "#{joyent}/#{module_name}.js"
    download = new Internet().download

    dirs.mkdirs library_path, ->
      fs.exists local, (exists) ->
        return on_resolve(null, local) if exists
        download.from(url).to local, (err) ->
          on_resolve(err, local)
