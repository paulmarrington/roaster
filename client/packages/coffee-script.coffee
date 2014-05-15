# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
dependency = require 'dependency'

module.exports = dependency(
  coffeescript: 'https://raw.githubusercontent.com/'+
  'jashkenas/coffee-script/master'+
  '/extras/coffee-script.js|coffee-script/coffee-script'
  '/ext/coffee-script/coffee-script.js'
  )
