# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

roaster.codemirror_base = '/ext/codemirror/codemirror'

module.exports = roaster.dependency(
  codemirror: 'http://codemirror.net/codemirror.zip|codemirror'
  "#{roaster.codemirror_base}/lib/codemirror.js",
  "#{roaster.codemirror_base}/addon/mode/loadmode.js",
  "#{roaster.codemirror_base}/lib/codemirror.css"
  )
