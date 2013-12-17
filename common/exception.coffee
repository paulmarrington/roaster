# Copyright (C) 2013 paul@marrington.net, see /GPL for license

class Exception extends Error
  constructor: (message, other_error) ->
    super message
    @[key] = value for key, value of other_error
    if other_error?.stack
      @stack = "Error: #{message}\n#{other_error.stack}"
    @message += "\n#{message}"

module.exports = (message, other_error) ->
  new Exception(message, other_error)
