# Copyright (C) 2012,13 paul@marrington.net, see /GPL license
fs = require 'fs'; path = require 'path'
os = require 'os'; dirs = require 'dirs'
streams = require 'streams'

tmp_dir = os.tmpDir()

files =
  # returns a file on one path or null if it can't be found
  # next(full_path, base_path, rest)
  find: (name, next) ->
    find_one = (bases) ->
      return next() if bases.length is 0
      full_path = path.join (base = bases.shift()), name
      return find_one(bases) if full_path is '/'
      fs.exists full_path, (exists) ->
        return next(full_path, base, name) if exists
        find_one(bases)
    find_one dirs.bases.slice(0)

  copy: (source, target, next) ->
    done = (error = null) -> next error; done = ->
    input = fs.createReadStream(source).on 'error', done
    output = fs.createWriteStream(target)
    output.on('error', done).on('close', done)
    input.pipe output

  size: (name, next) ->
    fs.stat name, (err, stat) -> next err, stat?.size

  is_dir: (name, next) -> fs.stat name, (err, stat) ->
    next err, stat?.isDirectory()

  save: (final_resting_place, inputs..., next) ->
    target = path.basename final_resting_place
    building_place = path.join tmp_dir, target
    dirs.mkdirs path.dirname(final_resting_place), ->
      file = fs.createWriteStream(building_place)
      streams.cat inputs..., file, (error) ->
        return next(error) if error
        fs.unlink final_resting_place, ->
          fs.rename building_place, final_resting_place, next
  # delete target if dir or file
  rm: (name, next) ->
    files.is_dir name, (error, is_dir) ->
      return next(error) if error
      return dirs.rmdirs(name, next) if is_dir
      fs.unlink name, next
  # move or rename a file
  mv: (from, to, next) ->
    files.join from, to, (to) -> fs.rename from, to, next
  # join paths - dropping file names until last...
  join: (base_path, last, next) ->
    files.is_dir base_path, (err, is_dir) ->
      if not is_dir
        filename = path.basename base_path
        base_path = path.dirname base_path
      result = path.join base_path, last
      files.is_dir result, (err, is_dir) ->
        if filename and is_dir
          result = path.join result, filename
        next(result)

module.exports = files