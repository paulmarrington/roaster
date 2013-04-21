# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

# Load html5 wysiwig editor.
# require('client/sceditor')() -> do-something()
module.exports = (next) ->
  steps(
    ->  @package 'jquery'
    ->  roaster.dependency(
          sceditor: 'https://codeload.github.com/samclarke/SCEditor/zip/v1.4.2'
          '/ext/sceditor/SCEditor-1.4.2/minified/themes/default.min.css'
          '/ext/sceditor/SCEditor-1.4.2/minified/jquery.sceditor.xhtml.min.js'
          )(next)
    )
