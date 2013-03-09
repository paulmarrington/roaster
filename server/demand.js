// Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
var path = require('path'), util = require('util')
var prefix = path.join(process.env.uSDLC_node_path, "ext")
var EventEmitter = require('events').EventEmitter

// Load npm module if new, otherwise behave as require does

var Demand = function(name, on_load) {
  EventEmitter.call(this)
  var required
  try {
    required = require(name)
  } catch(error) {
    var npm = require("ext/node/lib/node_modules/npm")
    npm.load({prefix: prefix}, function(err, npm) {
      try {
        npm.commands.install([name], 
          function() { required = require(name) })
      } catch(error) {
        this.emit('error', error)
        return
      }
    })
  }
  callback(required)
}
util.inherits(Demand, EventEmitter);

module.exports = function(modules) { new Demand(modules) }