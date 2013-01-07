# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
morph = require 'morph/less'; respond = require 'http/respond'

module.exports = (exchange) -> respond.morph_gzip_reply exchange, morph
