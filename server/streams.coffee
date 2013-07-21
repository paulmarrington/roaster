# Copyright (C) 2013 paul@marrington.net, see GPL for license
stream = require 'stream'
  
class String_to_Stream extends stream.Readable
  constructor: (@string) ->
    super()
    @done = false
  _read: (size) ->
    return @push(null) if @done
    @push @string
    @done = true

String::to_stream = -> new String_to_Stream(@.toString())