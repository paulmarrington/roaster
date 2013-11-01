# Copyright (C) 2013 paul@marrington.net, see /GPL for license
Queue = require 'common/queue'; requires = require 'requires'

module.exports = Queue.instance
module.exports.mixin = Queue.mixin
# The ubiquitous mix-in - asnchronous loading
Queue.mixin {requires}
