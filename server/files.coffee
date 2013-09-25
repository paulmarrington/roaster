# Copyright (C) 2012,13 paul@marrington.net, see /GPL license
fs = require 'fs'; path = require 'path'
steps = require 'steps'; os = require 'os'
dirs = require 'dirs'

tmp_dir = os.tmpDir()

module.exports = files =
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
    fs.stat name, (error, stat) -> next error, stat?.size

  is_dir: (name, next) -> fs.stat name, (error, stat) ->
    next error, stat?.isDirectory()

  save: (final_resting_place, inputs..., next) ->
    target = path.basename final_resting_place
    building_place = path.join tmp_dir, target

    steps(
      ->  @on 'error', (error) -> console.log error; @abort next, error
      ->  dirs.mkdirs path.dirname(final_resting_place), @next
      ->  @file = fs.createWriteStream(building_place)
      ->  @cat inputs..., @file
      ->  fs.unlink final_resting_place, @next
      ->  fs.rename building_place, final_resting_place, @next
      ->  next()
    )
    
steps.queue.mixin {dirs, files, fs}
