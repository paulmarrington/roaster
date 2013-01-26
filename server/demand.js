// Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
var path = require('path')
var prefix = path.join(process.env.uSDLC_node_path, "ext")

// Load npm module if new, otherwise behave as require does
module.exports = function(name, callback) {
  var required
  try {
    required = require(name)
  } catch(error) {
    var npm = require("npm")
    npm.load({prefix: prefix}, function(err, npm) {
      try {
        npm.commands.install([name], function() { callback(null, require(name)) })
      } catch(error) {
        callback(error)
      return
      }
    })
    return
  }
  callback(null, required)
}
