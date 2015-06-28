# Copyright (C) 2014 paul@marrington.net, see /GPL license
Resource = require 'model/Resource'

module.exports = class File extends Resource
  constructor: (@file_name, service) ->
    super(@file_name, "filesystem", service)

  read: (read) ->
    if @value.contents?
      # CKEditor needs to process a recent write
      return process.nextTick => read @value.contents
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
    try patch.create @file_name, @value.original, @value.contents, (changes) =>
      try @rest.update changes, (err, response) =>
        try
          if response then response = JSON.parse response
          else err = "Empty Response"
          if err
            @delayed_write() # try again later
            message "Error: Merging - #{@file_name}, #{err}"
            return @emit 'failure', err ? response
          if response.error
            message response.message
            # write will rename differing server copy to one with datestamp
            @rest.write @value.contents, (err, response) =>
              message err ? response.message
            @emit 'failure', 'merging'
          @storage.update original: @value.contents, contents: null
          message("Saved - #{@file_name}")
          @emit 'written', response
        finally @processing = false
      finally @processing = false
    finally @processing = false
