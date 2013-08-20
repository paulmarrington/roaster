# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

base = '/ext/jquery/jstree/jstree-master/dist'
roaster.jstree_theme_directory = "#{base}/themes/default"

module.exports = roaster.dependency(
  jstree: 'https://codeload.github.com/vakata/jstree/zip/master|jquery/jstree'
  "#{base}/jstree.js"
)
