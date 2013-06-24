# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

base = 'http://code.jquery.com/ui/1.10.3'
# https://github.com/ROMB/jquery-dialogextend

module.exports = roaster.dependency(
  jqueryui: "#{base}/jquery-ui.js|jquery/jquery-ui"
  jqueryuicss: "#{base}/themes/smoothness/jquery-ui.css|jquery/jquery-ui"
  dialogextend: "https://raw.github.com/ROMB/jquery-dialogextend/"+
    "master/build/jquery.dialogextend.min.js|jquery/jquery.dialogextend.min"
  '/ext/jquery/jquery-ui.js', '/ext/jquery/jquery-ui.css',
  '/ext/jquery/jquery.dialogextend.min.js'
)
