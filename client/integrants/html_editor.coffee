# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'Integrant'

mods = 'open,tabs,toolbar'
picture =
  html_editor: mvc: "panel_stack", require: mods, cargo:
    tabs:
      mvc: 'tab_view'
      cargo:
        Font:      selected: true
        Paragraph: {}
        Insert:    {}
        Form:      {}
        View:      {}
    doc:
      style: height: '100%'
      init: (pic, panel, next) -> @open.editor(panel, next)

class HtmlEditorView extends Integrant
  init: (done) -> @cargo picture, done 
   
module.exports = HtmlEditorView