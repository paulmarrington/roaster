# Copyright (C) 2015 paul@marrington.net, see /GPL for license
class Commands
  constructor: ->
    @add @extra_commands
    
  add: (commands) ->
    for k, v of commands then do (k, v) =>
      CodeMirror.commands[k] = (args...) =>
        v.apply @, args
    
  extra_commands:
    fold_at_cursor: (cm) -> cm.foldCode(cm.getCursor())
      
    view_source: (cm) ->
      if cm.somethingSelected()
        source = cm.doc.getSelection()
      else
        source = cm.doc.getValue()
      roaster.modal (panel) =>
        panel.innerHTML = "<pre></pre>"
        panel = panel.firstChild
        try
          code = @vc.compile.code(source, bare:true)
          if code
            CodeMirror.runMode code.source, code.type, panel
            panel.classList.add 'cm-s-default'
        catch e
          location = JSON.stringify(e.location)
          panel.innerHTML = "#{e}<br>#{location}"
          
    toggle_option: (cm, name) ->
      value = not cm.getOption(name)
      CodeMirror.commands.set_option(cm, name, value)
      
    set_option: (cm, name, value) ->
      cm.setOption(name, value)
      opt = {}
      for k,v of cm.options when not v instanceof RegExp
        opt[k] = v if k isnt 'value'
      localStorage['CodeMirrorOptions'] =
        JSON.stringify(opt)

    set_mode: (cm, mode) ->
      CodeMirror.commands.set_option(cm, 'keyMap', mode)
      prepare_menu(cm)
      
    auto_complete: (cm) ->
      anyword = CodeMirror.hint.anyword
      notOnly = -> # don't show if an exact match
        result = anyword.apply null, arguments
        list = result.list
        result.list = [] if list.length is 1 and
          list[0].length is (result.to.ch - result.from.ch)
        return result
      CodeMirror.showHint(cm, notOnly, completeSingle: false)
      
    insertTab: (cm) ->
      tab = cm.getOption("indentUnit") + 1
      cm.replaceSelection(spaces[0..tab], "end", "+input")

    save: (cm) -> @vc.save()

spaces = "                "

module.exports = Commands