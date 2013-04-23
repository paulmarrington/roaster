# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

# Load html5 wysiwig editor.
# require('client/sceditor')() -> do-something()
module.exports = (next) ->
  roaster.stylus = commands:
    add: tooltip: 'New document', exec: ->
    open: tooltip: 'Open document', exec: ->
    save: tooltip: 'Save document', exec: ->
    indent: tooltip: 'Indent Block', exec: -> @execCommand 'indent'
    outdent: tooltip: 'Outdent Block', exec: ->@execCommand 'outdent'
    removeformat: tooltip: 'Remove Formatting', exec: ->@execCommand 'removeformat'

  for level in [1..4]
    h = "h#{level}"
    roaster.stylus.commands[h] =
      tooltip: "Heading Level #{level}"
      exec: -> @execCommand 'formatBlock', h

  steps(
    ->  @package 'jquery', 'silk'
    ->  roaster.dependency(
          sceditor: 'https://codeload.github.com/samclarke/SCEditor/zip/v1.4.2'
          '/ext/sceditor/SCEditor-1.4.2/minified/themes/default.min.css'
          '/ext/sceditor/SCEditor-1.4.2/minified/jquery.sceditor.xhtml.min.js'
          )(next)
    )
