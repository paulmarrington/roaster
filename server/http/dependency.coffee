# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
internet = require('internet')(); path = require 'path'; dirs = require 'dirs'
fs = require 'fs'; steps = require 'steps'; files = require 'files'

module.exports = (exchange) ->
  results = {}

  download = (key, url, next) ->
    file = path.basename url
    file = "#{key}.#{file}" if file.indexOf(key) is -1
    file = dirs.base 'ext', file
    steps(
      ->  @long_operation()
      ->  fs.exists file, @next (exists) -> if exists then @abort(); next(null)
      ->  internet.download.from(url).to file, @next
      ->  next(file)
      )

  process_zip = (file, to, next) ->
    console.log "UNZIP '#{file}' to '#{to}'"
    base = dirs.base 'ext', to
    steps(
      ->  @requires 'adm-zip'
      ->  new @adm_zip(file).extractAllTo base, true
      ->  next()
      )

  process_file = (file, to, next) ->
    name_to_use = dirs.base 'ext', "#{to}#{path.extname(file)}"
    steps(
      ->  dirs.mkdirs path.dirname(name_to_use), @next
      ->  files.copy file, name_to_use, next
    )

  load = (key, url, next) ->
    [url, to, rename] = url.split '|'; to ?= key
    download key, url, (file) ->
      return next() if not file
      results[key] = true
      if path.extname(url) is '.zip' or url.indexOf('/zip/') isnt -1
        action = process_zip
      else
        action = process_file
      action file, to, ->
        if rename
          [from, to] = rename.split '='
          fs.rename from, to, next
        else
          next()

  steps(
    ->  @long_operation()
    ->  for key, url of exchange.request.url.query
          @call -> load key, url, @parallel()
    ->  exchange.respond.json results
    )
