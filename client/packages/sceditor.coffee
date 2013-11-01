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

module.exports = (next) -> queue ->
  @package 'jquery', 'silk', @next ->
    roaster.dependency(
      sceditor: 'https://codeload.github.com/samclarke/SCEditor/zip/v1.4.2'
      '/ext/sceditor/SCEditor-1.4.2/minified/themes/default.min.css'
      '/ext/sceditor/SCEditor-1.4.2/minified/jquery.sceditor.xhtml.min.js'
      )(next)
# # Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

# toolbar =
# "add,open,save|
# h1,h2,h3,h4|
# bold,italic,underline,strike,subscript,superscript|
# indent,outdent|
# left,center,right,justify|
# font,size,color,removeformat|
# bulletlist,orderedlist|
# table|
# code,quote|
# horizontalrule,image,email,link,unlink|
# print,source"

# uSDLC2_sceditor_commands =
#   add: tooltip: 'New document', exec: ->
#   open: tooltip: 'Open document', exec: ->
#   save: tooltip: 'Save document', exec: ->

# roaster.load "sceditor", ->
#   for name, cmd of roaster.sceditor_commands
#     $.sceditor.command.set name, cmd
#   for name, cmd of uSDLC2_sceditor_commands
#     $.sceditor.command.set name, cmd
#   $('#sceditor').sceditor(
#     toolbar: toolbar
#     plugins: "xhtml"
#     style: "/page.stylus"
#     emoticons: []
#     emoticonsEnabled: false
#     width: '100%'
#     height: '100%'
#     autofocus: true
#   )
# // Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
# btn_img(key,name)
#   .sceditor-button-{key} div
#     background url('/ext/silk/icons/'+name+'.png') !important

# btn_img('add', 'report_add')
# btn_img('open', 'report_edit')
# btn_img('save', 'report_disk')
# btn_img('indent', 'text_indent')
# btn_img('outdent', 'text_indent_remove')
# btn_img('removeformat', 'style_delete')

# for level in 1 2 3 4
#   btn_img('h'+level, 'text_heading_'+level)
