# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Internet = require 'internet'; path = require 'path'
dirs = require 'dirs'; fs = require 'fs'
files = require 'files'; npm = require 'npm'
# packages is a string of the form "url|to|rename"
#   url - to download file from
#   to - subdirectory to unzip into (optional)
#   rename - file in archive if there is only one
module.exports = (packages, next) ->
  results = {}

  count = 0; loaded = false
  for key, url of packages
    [url, to, rename] = url.split '|'; to ?= key
    count++
    
    processed = (file) ->
      results[key] = file
      next(results) if loaded and not --count

    file = path.basename url
    file = "#{key}.#{file}" if file.indexOf(key) is -1
    file = dirs.base 'ext', file
    downloader = new Internet().download
    
    fs.exists file, (exists) ->
      return next() if exists
      downloader.from(url).to file, ->
        if path.extname(url) is '.zip' or
        url.indexOf('/zip/') isnt -1
          base = dirs.base 'ext', to
          npm 'adm-zip', (error, adm_zip) ->
            return processed(error) if error
            new adm_zip(file).extractAllTo base, true
            return processed(base) if not rename
            fs.readdir base, (error, files) ->
              if error
                console.log "Error in package for ", base
                return processed()
              files = files.filter (file) -> file[0] isnt '.'
              return processed() if files.length isnt 1
              fs.rename path.join(base,files[0]),
                path.join(base, rename), -> processed(base)
        else # not an archive
          extname = path.extname(file)
          name_to_use = dirs.base 'ext', "#{to}#{extname}"
          dirs.mkdirs path.dirname(name_to_use), ->
            files.copy file, name_to_use, (error) ->
              if error
                console.log "Error in copy package for ", file
                return processed()
              return processed(name_to_use) if not rename
              rename = rename.split('=')
              fs.rename rename..., -> processed(rename[1])
  loaded = true
