# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
morph = require('morph').multi_morph; path = require 'path'
dirs = require 'dirs'; require 'common/strings'

joint = '.js': ';\n'

# Given a base path and mask an file-type, concatenate
module.exports = (exchange, next) ->
  parts = exchange.request.filename.split '.'
  base = dirs.base parts[0]
  type = '.' + parts[parts.length - 2]
  exclude = new RegExp(exchange.request.url.query.exclude ? '^$')
  exchange.respond.set_mime_type type
  exchange.respond.static_file()

  concat = ->
    text = []
    # Read all files into a contiguous string
    read_dir = (from) ->
      for file in fs.readdirSync from
        if file[0] isnt '.' and not exclude.test(file)
          file_path = path.join(from, file)
          stats = fs.lstatSync(file_path)
          if stats.isDirectory()
            read_dir(file_path)
          else if file_path.ends_with(type)
            text.push fs.readFileSync(file_path)
    read_dir base
    return text.join(joint[type] ? '')

  morph base, concat, type, (error, target, code, save) ->
    save(null, code) if code
    exchange.request.filename = target
    next error, exchange
