/* Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license */

// start by loading modules required for base operation
var modules = [
  'send', 'cookies', 'node-watch', 'faye',
  'coffee-script', 'LiveScript', 'kaffeine'
]
// Now load languages that can be used in node requires()
// js: javascript comes for free with V8
extend_require = require('morph').extend_require
extend_for = function(compile, ext) {
  extend_require(ext, function(error, filename, content, next) {
    if (content) {
        js = compile(content, {filename:filename})
        next(null, js)
    }
  })
}

// load required modules and when done extend requires and go on
// with processing. Sequential as npm requires that dammit
var demand = require('demand')
loader = function(index) {
  demand(modules[index], function() {
    if (++index < modules.length) {
      loader(index)
    } else {
      extend_for(require('coffee-script').compile, '.coffee')
      extend_for(require('LiveScript').compile, '.ls')
      // extend_for('typescript', '.ts')
      // extend_for('lispyscript', '.lispy')
      // extend_for('amber', '.amber') //  (Smalltalk)
      // extend_for(require('kaffeine').fn.compile, '.k')

      // and lastly, require the main module from the command line to run it
      require(process.argv[2])
    }
  })
}
loader(0) // kick off the module loading
