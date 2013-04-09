# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

tinymce = require('dependency')(
  tinymce: 'http://github.com/downloads/tinymce/tinymce/tinymce_3.5.8.zip'
  '/ext/tinymce/jscripts/tiny_mce/tiny_mce.js'
  )
# Load html5 wysiwig editor.
# require('client/aloha')() -> do-something()
module.exports = (next) -> tinymce.get(next)