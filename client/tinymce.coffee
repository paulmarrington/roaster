# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

# Load html5 wysiwig editor.
# require('client/tinymce')() -> do-something()
module.exports = roaster.dependency(
  tinymce: 'http://github.com/downloads/tinymce/tinymce/tinymce_3.5.8.zip'
  '/ext/tinymce/jscripts/tiny_mce/tiny_mce.js'
  )
