# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

base = 'http://code.jquery.com/ui/1.10.3'
# https://github.com/ROMB/jquery-dialogextend

module.exports = roaster.dependency(
  jqueryui: "#{base}/jquery-ui.js|jquery/jquery-ui"
  jqueryuithemes: "https://codeload.github.com/taitems/Aristo-jQuery-UI-Theme"+
    "/zip/master|jquery|ext/jquery/Aristo-jQuery-UI-Theme-master=ext/jquery/theme"
  dialogextend: "https://raw.github.com/ROMB/jquery-dialogextend/"+
    "master/build/jquery.dialogextend.min.js|jquery/jquery.dialogextend.min"
  '/ext/jquery/jquery-ui.js', '/ext/jquery/theme/css/Aristo/Aristo.css',
  '/ext/jquery/jquery.dialogextend.min.js'
)
