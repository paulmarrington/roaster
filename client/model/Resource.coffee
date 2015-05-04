# Copyright (C) 2014 paul@marrington.net, see /GPL license
Storage = require "Storage"; Restful = require 'model/Restful'
events = require 'events'

module.exports = class Resource extends events.EventEmitter
  constructor: (@file_name, type="resource", @service) ->
    @storage = new Storage @file_name, type
    @value = @storage.value
    @service ?= "/server/http/file.coffee?name="
    @rest = new Restful @service+@file_name
    @value.file_name = @file_name
    
  read: (read) ->
    if @value.original 
      @server_newer (local_outdated) ->
        if (local_outdated)
          @load_from_server -> # load now, use after refresh of page
            message 'Warn: Update - Refresh to update resources'
      read @value.original # pronounce as 'red'
    else
      @load_from_server read
      
  server_newer: (next) ->
    @rest.head (err, meta) =>
      return @emit 'error', err if err
      next meta["Last-Modified"] > @value.last_modified
      
  load_from_server: (read) ->
    @rest.read (err, data) =>
      return @emit 'error', err, '' if err
      last_modified = @rest.meta()["Last-Modified"]
      @storage.update { original: data ? '', last_modified }
      read @value.original # pronounce as 'red'

  write: (contents) ->
    message 'Error: Resource - Resources are read-only'
    
  flush: ->