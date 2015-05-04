# Copyright (C) 2014 paul@marrington.net, see /GPL license
Resource = require 'model/Resource'

module.exports = class File extends Resource
  constructor: (@file_name, url) ->
    super(@file_name, "filesystem")
    
  read: (read) ->
    if @value.contents
      return read @value.contents
    @load_from_server read

  write: (contents) ->
    message 'Clear: Saved'
    # save contents in browser persistent storage
    @storage.save @value.contents = contents
    @delayed_write()
    
  delayed_write: ->
    clearTimeout @timer
    @timer = setTimeout (=> @flush()), 30000
      
  flush: -> # send changes to the server immediately (if possible)
    patch = require 'common/patch'
    return if @processing # don't flush while flushing
    clearTimeout @timer
    return if @value.contents is @value.original
    @processing = true
    patch.create @file_name, @value.original, @value.contents,
    (changes) =>
      @rest.update changes, (err, response) =>
        if err or response.error
          @delayed_write() # try again later
          @processing = false
          message('Error: Merge - #{@file_name}')
          return @emit 'error', err ? response
        delete @value.contents
        @storage.save @value.original = @value.contents
        @processing = false
        message("Saved - #{@file_name}")
        @emit 'written', response