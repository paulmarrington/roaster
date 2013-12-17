# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
dependency = require 'dependency'

# usdlc.ace_base = '/ext/ace/ace-master/src-min-noconflict'
roaster.ace_base = '/ext/ace/ace-builds-master/src-noconflict'

module.exports = dependency(
  ace: 'https://codeload.github.com/ajaxorg/ace-builds/zip/master|ace'
  "#{roaster.ace_base}/ace.js", "#{roaster.ace_base}/ext-settings_menu.js"
  )
