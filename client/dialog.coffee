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
dialogs = roaster.dialogs = {}
default_options =
  closable:         false
  maximizable:      true
  minimizable:      true
  collapsable:      true
  minimizeLocation: 'right'
  dblclick:         'maximize'
  icons:            {collapse: "ui-icon-close"}
  width:            600
  collapse:         (evt, dlg) -> $(evt.target).dialog('close')
  
$.widget "ui.dialog", $.ui.dialog,
  _moveToTop: (event, silent) ->
    moved = false
    # // *** WORKAROUND FOR THE FOLLOWING ISSUES ***
    # //
    # // New stacking feature causing iframe problems when changing dialog
    # // http://bugs.jqueryui.com/ticket/9067
    # //
    # // Moving an IFRAME within the DOM tree results in reloading of content
    # // https://bugs.webkit.org/show_bug.cgi?id=13574
    dialogs = @uiDialog.nextAll(":visible")
    if dialogs.length > 0
      moved = true
      if dialogs.find('iframe').length > 0
          @uiDialog.insertAfter(dialogs.last())
      else
          dialogs.insertBefore(@uiDialog)
    @_trigger("focus", event) if moved && !silent
    return moved
            
module.exports = (options...) ->
  name = options[0].name
  if not dlg = dialogs[name]
    options = _.extend {}, default_options, options...
    dlg = dialogs[name] = $('<div>').addClass('dialog').appendTo(document.body)
    dlg.dialog(options).dialogExtend(options)
    if options.fix_height_to_window
      set_height = ->
        height = $(window).height() - options.fix_height_to_window
        dlg.dialog 'option', 'height', height
        options.resizeStop?(dlg)
      setTimeout(set_height, 500)
    options?.init(dlg)
  else
    options = options[0]
    dlg.dialog 'option', 'title', options.title
    dlg.dialogExtend('restore')
    dlg.dialog('open').dialog('moveToTop')
    dlg.dialog('option', 'position', options.position) if options.position
  options?.fill(dlg)
  return dlg
