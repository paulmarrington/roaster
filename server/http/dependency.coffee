# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
Internet = require 'internet'; path = require 'path'
dirs = require 'dirs'; fs = require 'fs'
files = require 'files'; npm = require 'npm'

module.exports = (exchange) ->
  results = {}

  download = (key, url, next) ->
    file = path.basename url
    file = "#{key}.#{file}" if file.indexOf(key) is -1
    file = dirs.base 'ext', file
    downloader = new Internet().download
    
    fs.exists file, (exists) ->
      return next() if exists
      downloader.from(url).to file, -> next(file)

  process_zip = (file, to, rename, next) ->
    base = dirs.base 'ext', to
    npm 'adm-zip', (error, adm_zip) ->
      return next(error) if error
      new @adm_zip(file).extractAllTo base, true
      fs.readdir base, (error, files) ->
        return next(error) if error
        files = files.filter (file) -> file[0] isnt '.'
        return next() if @files.length isnt 1 or not rename
        fs.rename path.join(base,@files[0]),
        path.join(base, rename), next

  process_file = (file, to, rename, next) ->
    name_to_use = dirs.base 'ext', "#{to}#{path.extname(file)}"
    dirs.mkdirs path.dirname(name_to_use), ->
      files.copy file, name_to_use, (error) ->
        return next(error) if error or not rename
        fs.rename rename.split('=')..., next

  load = (key, url, next) ->
    [url, to, rename] = url.split '|'; to ?= key
    download key, url, (file) ->
      return next() if not file
      results[key] = true
      if path.extname(url) is '.zip' or
      url.indexOf('/zip/') isnt -1
        process_zip file, to, rename, next
      else
        process_file file, to, rename, next

  count = 0; loaded = false
  for key, url of exchange.request.url.query
    count++
    load key, url, ->
      if loaded and not --count
        exchange.respond.json results
  loaded = true
