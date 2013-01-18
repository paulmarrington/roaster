# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

module.exports =
  # call before anything is done to initialise the server
  pre: (environment) -> console.log("No pre call configured")
  # call after server has started listening for connections
  post: (environment) -> console.log("No post call configured")
