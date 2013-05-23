// Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
var path = require('path')
var prefix = path.join(process.env.uSDLC_node_path, "ext")

load = function(name, on_loaded) {
    var npm = require("ext/node/lib/node_modules/npm")
    npm.load({prefix: prefix}, function(err, npm) {
        try {
            npm.commands.install([name], function() {
                on_loaded(null, require(name)) })
        } catch(error) {
            return on_loaded(error)
        }
    })
}
check_for_missing_requirement = function(name, error) {
    // error can be in required code or because code does not exist
    if (error.code !== 'MODULE_NOT_FOUND') throw error
    // must check it is the asked for not found, not inner require
    if (error.toString().indexOf(name + "'") === -1) throw error
}
// Load npm module if new, otherwise behave as require does
module.exports = function(name, on_loaded) {
    var required
    try {
        required = require(name)
    } catch(error) {
        check_for_missing_requirement(name, error)
        return load(name, on_loaded)
    }
    on_loaded(null, required)
}

module.exports.load = load
module.exports.check_for_missing_requirement = check_for_missing_requirement
