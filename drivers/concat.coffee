# Copyright (C) 2013 paul@marrington.net, see GPL for license
morph = require('morph').multi_morph; path = require 'path'
dirs = require 'dirs'; require 'common/strings'
fs = require 'fs'

joint = '.js': ';\n'

# Given a base path and mask an file-type, concatenate
module.exports = (exchange, next) ->
  query = exchange.request.url.query
  parts = exchange.request.filename.split '.'
  base = dirs.base parts[0]
  type = '.' + parts[parts.length - 2]
  exclude = (query.exclude ? '^$').trim()
  exclude = exclude.replace(/\)[^\)].+$/, ')') if exclude[0] is '('
  exclude = new RegExp(exclude)
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
