# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

# Load html5 wysiwig editor.
# require('client/sceditor')() -> do-something()
module.exports = (next) ->
  steps(
    ->  @requires '/client/jquery.coffee'
    ->  roaster.dependency(
          sceditor: 'https://github.com/samclarke/SCEditor/archive/v1.4.2.zip'
          '/ext/sceditor/jscripts/src/themes/default.less'
          '/ext/sceditor/jscripts/src/jquery.sceditor.js'
          ) @next
    )
