# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
dependency = require 'dependency'

module.exports = dependency(
  jsonlint: "https://raw.githubusercontent.com/"+
            "zaach/jsonlint/master/lib/jsonlint.js"+
            "|codemirror/jsonlint"
  '/ext/codemirror/jsonlint.js'
  )
