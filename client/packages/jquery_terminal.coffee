# Copyright (C) 2013 paul@marrington.net, see GPL for license
dependency = require 'dependency'

base = '/ext/jquery/terminal/jquery.terminal-master'

module.exports = dependency(
  jquery_terminal: 'https://codeload.github.com/jcubic/jquery.terminal/zip/master|jquery/terminal'
  "#{base}/js/jquery.mousewheel-min.js"
  "#{base}/js/jquery.terminal-src.js"
  "#{base}/css/jquery.terminal.css"
  )
