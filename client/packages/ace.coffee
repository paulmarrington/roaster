# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

# usdlc.ace_base = '/ext/ace/ace-master/src-min-noconflict'
usdlc.ace_base = '/ext/ace/ace-builds-master/src-noconflict'

module.exports = roaster.dependency(
  ace: 'https://codeload.github.com/ajaxorg/ace-builds/zip/master|ace'
  "#{usdlc.ace_base}/ace.js", "#{usdlc.ace_base}/ext-settings_menu.js"
  )
