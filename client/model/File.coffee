# Copyright (C) 2014 paul@marrington.net, see /GPL license
Resource = require 'model/Resource'

class File extends Resource
  constructor: (@file_name, url) ->
    url = (url ? "/server/http/file?name=") + @file_name
    super(@file_name, url, "filesystem")
    
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
    # these shenanigans so we send to server every 30 seconds
    end_timer: => clearTimeout @timer; delete @timer
    @timer = setTimeout (-> end_timer()), 30000 if not @timer
    # but only if the operator is not typing
    clearTimeout @rest
    @rest = setTimeout (=> @flush()), 2000
      
  flush: -> # send changes to the server immediately (if possible)
    patch = require 'common/patch.coffee'
    return if @processing # don't flush while flushing
    clearTimeout @rest
    clearTimeout @timer
    if @value.contents is @value.original
      return @emit 'written', 'identical'
    @processing = true
    patch.create file_name, @value.original, @value.content,
    (changes) ->
      rq = new XMLHttpRequest()
      failed = (type) ->
        @delayed_write() # try again later
        @processing = false
        my.emit 'error', rq.status ? type
      rq.addEventListener "error", failed
      rq.addEventListener "abort", failed
      rq.addEventListener "load",  =>
        return failed() if rq.status isnt 200
        response = JSON.parse rq.responseText
        if not response.error
          delete @value.contents
          @storage.save @value.original = @value.contents
          @processing = false
          message('Pass: Saved - #{@file_name}')
          @emit 'written', response
        else
          message('Error: Merge - #{@file_name}')
          @emit 'error', response
      rq.open 'PUT', @value.url, true
      rq.send changes
      
  module.exports = File