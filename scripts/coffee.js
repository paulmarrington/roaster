/* Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license */

// download coffee-script from npm if it hasn't been done before
coffee = require('coffee-script')
// set the extension to compile of the code is out of date using build
require('code-builder').extend_require('.coffee', function(error, filename, content, next) {
    if (error) throw error
    if (content) {
        js = coffee.compile(content, {filename:filename})
        next(null, js)
    }
})

// and lastly, require the main module from the command line to run it
require(process.argv[2]) // only works if build is really synchronous under the service
