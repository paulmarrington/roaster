# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

# Load html5 wysiwig editor.
# require('client/sceditor')() -> do-something()
remove_format = ->
  @execCommand 'formatBlock', 'div'
  @execCommand 'removeformat'

roaster.sceditor_commands =
  add: tooltip: 'New document', exec: ->
  open: tooltip: 'Open document', exec: ->
  save: tooltip: 'Save document', exec: ->
  indent: tooltip: 'Indent Block', exec: -> @execCommand 'indent'
  outdent: tooltip: 'Outdent Block', exec: -> @execCommand 'outdent'
  removeformat: tooltip: 'Remove Formatting', exec: remove_format

for level in [1..4] then do ->
  h = "h#{level}"
  roaster.sceditor_commands[h] =
    tooltip: "Heading Level #{level}"
    exec: -> @execCommand 'formatBlock', h

module.exports = (next) ->
  roaster.packages 'jquery', 'silk', ->
    roaster.dependency(
      sceditor: 'https://codeload.github.com/samclarke/SCEditor/zip/v1.4.2'
      '/ext/sceditor/SCEditor-1.4.2/minified/themes/default.min.css'
      '/ext/sceditor/SCEditor-1.4.2/minified/jquery.sceditor.xhtml.min.js'
      )(next)