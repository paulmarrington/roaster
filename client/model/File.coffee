# Copyright (C) 2014 paul@marrington.net, see /GPL license
Resource = require 'model/Resource'

module.exports = class File extends Resource
  constructor: (@file_name, url) ->
    super(@file_name, "filesystem")
    
  read: (read) ->
    return read @value.contents if @value.contents?
    @load_from_server read

  write: (contents) ->
    return if contents is (@value.contents ? @value.original)
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
    return if not @value.contents? or @value.contents is @value.original
    @processing = true
    patch.create @file_name, @value.original, @value.contents,
    (changes) =>
      @rest.update changes, (err, response) =>
        response = JSON.parse response
        if err
          @delayed_write() # try again later
          @processing = false
          message "Error: Merging - #{@file_name}, #{err}"
          return @emit 'error', err ? response
        if response.error
          message response.message
          return @emit 'merge-failure'
        @storage.update original: @value.contents, contents: null
        @processing = false
        message("Saved - #{@file_name}")
        @emit 'written', response