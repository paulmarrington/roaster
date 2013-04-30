/* Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license */

// start by loading modules required for base operation
var modules = [
  'send', 'coffee-script', 'underscore'
]
// Now load languages that can be used in node requires()
// js: javascript comes for free with V8
extend_require = require('morph').extend_require
extend_for = function(compile, ext) {
  extend_require(ext, function(error, filename, content, next) {
    if (content) {
      try {
        js = compile(content, {filename:filename})
      } catch (error) {
        console.log("Error compiling "+filename+ ": " + error)
        js = ''
      }
      next(null, js)
    }
  })
}

// load required modules and when done extend requires and go on
// with processing. Sequential as npm requires that dammit
var npm = require('npm')
loader = function(index) {
  npm(modules[index], function() {
    if (++index < modules.length) {
      loader(index)
    } else {
      extend_for(require('coffee-script').compile, '.coffee')
      // and lastly, require the main module from the command line to run it
      require(process.argv[2])
    }
  })
}
loader(0) // kick off the module loadingls