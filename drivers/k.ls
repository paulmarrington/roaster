# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

# Kaffeine is a set of extensions to the Javascript syntax that attempt to make
# it nicer to use. It compiles directly into javascript that is very similar,
# readable and line for line equivalent to the input.
# http://weepy.github.com/kaffeine/index.html
require! 'morph/kaffeine'

module.exports = (exchange, next) -> exchange.respond.morph kaffeine, next
