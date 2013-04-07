# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
internet = require('internet')(); path = require 'path'; dirs = require 'dirs'
fs = require 'fs'; steps = require 'steps'

module.exports = (exchange) ->
  results = {}

  load_archive = (key, url, on_loaded) ->
    archive = dirs.base 'ext', path.basename url
    base = dirs.base 'ext', key
    steps(
      ->  @long_operation()
      ->  fs.exists archive, @next (exists) -> if exists then on_loaded @abort()
      ->  internet.download.from(url).to archive, @next
      ->  dirs.rmdirs base, @next
      ->  @requires 'adm-zip'
      ->  new @adm_zip(archive).extractAllTo base, true
      ->  results[key] = true; on_loaded()
      )

  steps(
    ->  @long_operation()
    ->  for key, url of exchange.request.url.query
          @call -> load_archive key, url, @parallel()
    ->  exchange.respond.json results
    )
