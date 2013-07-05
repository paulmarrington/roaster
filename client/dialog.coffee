# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

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
dialogs = {}
default_options =
  closable:         false
  maximizable:      true
  minimizable:      true
  collapsable:      true
  minimizeLocation: 'right'
  dblclick:         'maximize'
  icons:            {collapse: "ui-icon-close"}
  width:            600
  collapse:         (evt, dlg) -> usdlc.instrument_window.dialog('close')

module.exports = (options...) ->
  name = options[0].name
  if not dlg = dialogs[name]
    options = _.extend {}, default_options, options...
    dlg = dialogs[name] = $('<div>').addClass('dialog').appendTo(document.body)
    dlg.dialog(options).dialogExtend(options)
    options?.init(dlg)
    if options.fix_height_to_window
      (w = $(window)).resize ->
        $(dlg).css height: w.height() - options.fix_height_to_window
      w.resize()
  else
    options = options[0]
    dlg.dialog 'option', 'title', options.title
    dlg.dialogExtend('restore')
    dlg.dialog('open').dialog('moveToTop')
    dlg.dialog('option', 'position', options.position) if options.position
  options?.fill(dlg)
  return dlg
