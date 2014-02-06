# Copyright (C) 2014 paul@marrington.net, see GPL for license
path = require 'path'; newer = require 'newer'
fs = require 'fs'

module.exports = walk = (from, complete, found) ->
  base = from.length
  read_dir = (from, dir_read) ->
    process_file = (file, next) ->
      return next() if file[0] is '.'
      file_path = path.join(from, file)
      fs.lstat file_path, (error, stats) ->
        return next() if error
        if stats.isDirectory()
          read_dir file_path, next
        else
          found file_path[base..-1], stats, next
    fs.readdir from, (error, files) ->
      do process_one = ->
        return dir_read() if not files?.length
        process_file files.shift(), process_one
  read_dir(from, complete)

walk.newer = (sources..., target, filter, next) ->
  list = []
  do next_source = ->
    return next(list) if not sources.length
    source = sources.shift()
    walk source, next_source, (file, stats, next) =>
      from = "#{source}#{file}"
      if filter.test(from)
        to = "#{target}#{file}".replace(/\.java$/, '.class')
        list.push from if newer(from, to)
      next()
