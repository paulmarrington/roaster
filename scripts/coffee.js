/* Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license */

// set the extension to compile of the code is out of date using build
require('morph').extend_require('.coffee', function(error, filename, content, save) {
    if (error) throw error
    if (content) {
        js = require('coffee-script').compile(content, {filename:filename})
        save(null, js)
    }
})

// and lastly, require the main module from the command line to run it
require(process.argv[2]) // only works if build is really synchronous under the service
