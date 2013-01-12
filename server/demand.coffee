# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
fs = require 'file-system'

# Load npm module if new, otherwise behave as require does
module.exports = (name, callback) ->
    try
        required = require name
    catch error
        throw error
        npm = require("npm")
        prefix = fs.node "ext"
        npm.load {prefix: prefix}, (err, npm) ->
            try
                npm.commands.install [name], -> callback(null, require name)
            catch error
                callback error
            return
    callback null, required