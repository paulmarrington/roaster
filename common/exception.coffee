# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

class exception extends Error
  constructor: (message, other_error) ->
    super message
    @[key] = value for key, value of other_error
    @stack = "Error: #{message}\n#{other_error.stack}" if other_error?.stack
    @message += "\n#{message}"

module.exports = (message, other_error) -> new exception(message, other_error)
