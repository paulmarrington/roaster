# Copyright (C) 2012-15 paul@marrington.net, see GPL for license
fs = require 'fs'; path = require 'path'; dirs = require 'dirs'
patch = require 'common/patch', files = require 'files'
require 'Date'

module.exports = (exchange) ->
  error = (msg) ->
    exchange.respond.json error: true, message: "Error: "+msg

  switch exchange.request.method
    when 'GET'
      file = exchange.request.url.query.name
      file = dirs.base file if not path.isAbsolute file
      exchange.respond.static_file(file).send_static()

    when 'POST' # save file
      file_path = dirs.base name = exchange.request.url.query.name

      save_file = ->
        file = fs.createWriteStream file_path
        exchange.request.on 'data', (data) -> file.write data
        exchange.request.on 'end', -> file.end()
        file.on 'end',   ->
          exchange.respond.json message: file_path + " written"
        file.on 'error', (err) -> exchange.respond.error err

      files.size file_path, (err, size) =>
        if size
          name = name.replace(/(.*)\.(.*?)/, "$1.#{new Date().format()}.$2")
          older_path = dirs.base name
          fs.rename file_path, older_path, (err) ->
            if err then exchange.respond.error err
            else save_file()
        else save_file()


    when 'PUT' # patch file
      file_path = dirs.base exchange.request.url.query.name
      fs.readFile file_path, 'utf8', (err, html) ->
        exchange.respond.read_request (changes) ->
          patch.apply html ? '', changes, (html) ->
            if not html
              return exchange.respond.json error: true, \
                message: "Error: source differs from expected"
            fs.writeFile file_path, html, 'utf8', (err) ->
              return exchange.respond.error err if err
              exchange.respond.json message: file_path + " written"

    when 'DELETE'
      file_path = dirs.base exchange.request.url.query.name
      fs.unlink file_path, (err) ->
        exchange.respond.error "deleting "+file_path
