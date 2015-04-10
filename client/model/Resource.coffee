# Copyright (C) 2014 paul@marrington.net, see /GPL license
events = require 'events'; Storage = require "Storage"

class Resource extends events.EventEmitter
  constructor: (@file_name, type="resource") ->
    @storage = new Storage @file_name, type
    @value = @storage.value
    @value.url = @file_name
    
  read: (read) ->
    if @value.original
      @server_newer (newer) -> @load_from_server ->
        message 'Warn: Update - Refresh to update resources'
      read @value.original # pronounce as 'red'
    else
      @load_from_server read
      
  server_newer: (next) ->
    require.head @value.url, (last_modified) ->
      return last_modified > @value.last_modified
      
  load_from_server: (read) ->
    require.data @value.url, (err, contents, last_modified) ->
      if err
        @emit 'error', err
        return read ''
      @value.last_modified = last_modified
      @storage.save @value.original = contents ? ''
      read @value.original # pronounce as 'red'

  write: (contents) ->
    message 'Error: Resource - Resources are read-only'
    
  flush: ->
    
module.exports = Resource