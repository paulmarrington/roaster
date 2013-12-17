# Copyright (C) 2013 paul@marrington.net, see /GPL for license
faye = require(require('dirs').node('ext/node_modules/faye'))

module.exports = (url) -> return new faye.Client url
