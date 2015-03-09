# Copyright (C) 2013 paul@marrington.net, see /GPL for license

module.exports = (loaded) ->
  require.dependency(
    jsonlint: "https://raw.githubusercontent.com/"+
            "zaach/jsonlint/master/lib/jsonlint.js"+
            "|codemirror/jsonlint"
    '/ext/codemirror/jsonlint.js', loaded)
