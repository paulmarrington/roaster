# Copyright (C) 2013 paul@marrington.net, see /GPL for license
dependency = require 'dependency'

base = 'http://code.jquery.com/ui/1.10.3'
# https://github.com/ROMB/jquery-dialogextend

module.exports = dependency(
  jqueryui: "#{base}/jquery-ui.js|jquery/jquery-ui"
  jqueryuithemes: "http://jqueryui.com/resources/download/"+
    "jquery-ui-themes-1.10.3.zip|jquery/themes|themes"
  dialogextend: "https://raw.githubusercontent.com/ROMB/"+
    "jquery-dialogextend/"+
    "master/build/jquery.dialogextend.js|jquery/dialogextend"
  contextmenu: "https://raw.githubusercontent.com/mar10/"+
    "jquery-ui-contextmenu/master/"+
    "jquery.ui-contextmenu.js|jquery/contextmenu"
  '/ext/jquery/jquery-ui.js',
  '/ext/jquery/themes/themes/themes/smoothness/jquery-ui.css',
  '/ext/jquery/dialogextend.js', '/ext/jquery/contextmenu.js'
)
