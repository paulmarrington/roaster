# Copyright (C) 2012 paul@marrington.net, see GPL for license
fs = require 'fs'; path = require 'path'; dirs = require 'dirs'
patch = require 'common/patch'

module.exports = (exchange) ->
  error = (msg) ->
    exchange.respond.json error: true, message: "Error: "+msg
  switch exchange.request.method
    when 'GET'
      file = dirs.base exchange.request.url.query.name
      exchange.respond.static_file(file).send_static()
    
    when 'POST' # save file
      file_path = dirs.base exchange.request.url.query.name
      file = fs.createWriteStream file_path
      exchange.request.on 'data', (data) -> file.write data
      exchange.request.on 'end', -> file.end()
      file.on 'end',   ->
        exchange.respond.json message: file_path + " written"
      file.on 'error', (err) -> error err
      
    when 'PUT' # patch file
      file_path = dirs.base exchange.request.url.query.name
      fs.readFile file_path, 'utf8', (err, html) ->
        exchange.respond.read_request (changes) ->
          patch.apply html ? '', changes, (html) ->
            if not html
              return error "Error: source differs from expected"
            fs.writeFile file_path, html, 'utf8', (err) ->
              return error err if err
              exchange.respond.json message: file_path + " written"
    
    when 'DELETE'
      file_path = dirs.base exchange.request.url.query.name
      fs.unlink file_path, (err) -> error "deleting "+file_path