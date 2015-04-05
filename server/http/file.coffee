# Copyright (C) 2012 paul@marrington.net, see GPL for license
fs = require 'fs'; path = require 'path'; dirs = require 'dirs'
patch = require 'common/patch'

module.exports = (exchange) ->
  switch exchange.request.method
    when 'GET': # get file
      file = dirs.base exchange.request.url.query.name
      return exchange.respond.static_file(file).send_static()
    
    when 'POST': # save file
      file_path = dirs.base exchange.request.url.query.name
      file = fs.createWriteStream file_path
      exchange.request.on 'data', (data) -> file.write data
      exchange.request.on 'end', -> file.end()
      file.on 'end',   -> exchange.respond.json error : false
      file.on 'error', (err) -> exchange.respond.json error : err
      
    when 'PUT': # patch file
      name = exchange.request.url.query.name
      files.find name, (file_path) ->
        return if not file_path
        fs.readFile file_path, 'utf8', (err, html) ->
          exchange.respond.read_request (changes) ->
            patch.apply html ? '', changes, (html) ->
              if not html then return exchange.respond.json
                error: "source differs from expected"
              fs.writeFile filename, html, 'utf8', (err) ->
                return exchange.response.end() if not err
                exchange.respond.json error: err.message
    
    when 'DELETE':
      file_path = dirs.base exchange.request.url.query.name
      fs.unlink file_path, (err) ->
        exchange.respond.json error : err