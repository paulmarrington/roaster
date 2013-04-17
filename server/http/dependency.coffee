# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
internet = require('internet')(); path = require 'path'; dirs = require 'dirs'
fs = require 'fs'; steps = require 'steps'; files = require 'files'

module.exports = (exchange) ->
  results = {}

  download = (url, next) ->
    file = dirs.base 'ext', path.basename url
    steps(
      ->  @long_operation()
      ->  fs.exists file, @next (exists) -> if exists then @abort(); next(null)
      ->  internet.download.from(url).to file, @next
      ->  next(file)
      )

  process_archive = (key, file, next) ->
    base = dirs.base 'ext', key
    steps(
      ->  dirs.rmdirs base, @next
      ->  @requires 'adm-zip'
      ->  new @adm_zip(file).extractAllTo base, true
      ->  next()
      )

  process_file = (key, file, next) ->
    name_to_use = dirs.base 'ext', "#{key}#{path.extname(file)}"
    files.copy file, name_to_use, next

  load = (key, url, next) ->
    download url, (file) ->
      return next() if not file
      results[key] = true
      if path.extname(url) is '.zip'
        process_archive key, file, next
      else
        process_file key, file, next

  steps(
    ->  @long_operation()
    ->  for key, url of exchange.request.url.query
          @call -> load key, url, @parallel()
    ->  exchange.respond.json results
    )
