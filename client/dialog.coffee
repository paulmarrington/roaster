# Copyright (C) 2013 paul@marrington.net, see /GPL for license

# @window
#   name:   "Instrument",
#   title:  "Instrument #{section}",
#   url:    url,
#   after:  @next

# https://github.com/ROMB/jquery-dialogextend
# "closable" : true,
# "maximizable" : true,
# "minimizable" : true,
# "collapsable" : true,
# "dblclick" : "collapse",
# "titlebar" : "transparent",
# "minimizeLocation" : "right",
# "icons" : {
#   "close" : "ui-icon-circle-close",
#   "maximize" : "ui-icon-circle-plus",
#   "minimize" : "ui-icon-circle-minus",
#   "collapse" : "ui-icon-triangle-1-s",
#   "restore" : "ui-icon-bullet"
# },
# "load" : function(evt, dlg){ alert(evt.type); },
# "beforeCollapse" : function(evt, dlg){ alert(evt.type); },
# "beforeMaximize" : function(evt, dlg){ alert(evt.type); },
# "beforeMinimize" : function(evt, dlg){ alert(evt.type); },
# "beforeRestore" : function(evt, dlg){ alert(evt.type); },
# "collapse" : function(evt, dlg){ alert(evt.type); },
# "maximize" : function(evt, dlg){ alert(evt.type); },
# "minimize" : function(evt, dlg){ alert(evt.type); },
# "restore" : function(evt, dlg){ alert(evt.type); }
dialogs = roaster.dialogs = {}
roaster.dialog_position ?= ->
  my: "center top", at: "center top", of: window
default_options =
  closable:         true
  maximizable:      true
  minimizable:      true
  collapsable:      true
  minimizeLocation: 'right'
  dblclick:         'maximize'
#   icons:            {collapse: "ui-icon-close"}
#   collapse:         (evt, dlg) -> $(evt.target).dialog('close')

roaster.zindex = 200

$.widget "ui.dialog", $.ui.dialog,
  _moveToTop: (event, silent) ->
    if +@uiDialog.css('z-index') >= roaster.zindex - 1
      return false
    @uiDialog.css 'z-index', roaster.zindex++
    @_trigger("focus", event) if not silent
    return true

module.exports = (options_list..., next) ->
  if next not instanceof Function
    options_list.push next
    next = ->
  options_list.unshift default_options
  options = _.extend {}, default_options, options_list...
  set_height = ->
    height = $(window).height()
    dlg.dialog 'option', 'maxHeight', height - 20
    options.resizeStop?(dlg)
    if not options.position
      dlg.dialog "option", "position",
        roaster.dialog_position()
  if not dlg = dialogs[options.name]
    dlg = dialogs[options.name] = $('<div>').
      addClass('dialog').appendTo(document.body)
    dlg.dialog(options).dialogExtend(options)
    dlg.on 'resize', ->
      here = dlg.dialog "option", "position"
      dlg.dialog "option", "position", here
    dlg.click -> dlg.trigger 'resize'
    dlg.keyup -> dlg.trigger 'resize'
    options?.init(dlg)
  else
    dlg.dialog 'option', 'title', options.title
    dlg.dialogExtend('restore')
    dlg.dialog('open').dialog('moveToTop')
    if options.position
      dlg.dialog('option', 'position', options.position)
  dlg.dialog('option', 'closeOnEscape', false)
  options?.fill(dlg)
  setTimeout(set_height, 500)
  next(dlg)
