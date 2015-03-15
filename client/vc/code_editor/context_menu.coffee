# Copyright (C) 2015 paul@marrington.net, see /GPL for license
          
class ContextMenu
  prepare: (button) ->
    cm = @vc.editor
    key_map = {}
    one_map = (map) ->
      for key, cmd of map
        key_map[cmd] = '' if not key_map[cmd]
        key_map[cmd] += ' ' + key
      if typeof map.fallthrough is 'string'
        one_map(CodeMirror.keyMap[map.fallthrough])
      else if map.fallthrough
        for map in map.fallthrough
          one_map(CodeMirror.keyMap[map])
    one_map cm.options.extraKeys
    core = CodeMirror.keyMap[cm.options.keyMap]
    if not core.fallthrough
      core.fallthrough =
        CodeMirror.keyMap['default'].fallthrough
    one_map core

    menu = @vc.child('code_editor_menu')
    for a in menu.getElementsByTagName('a') \
    when action = a.getAttribute('action')
      if key = key_map[action]
        floater = "<div class='hint'>#{key}</div>"
        a.innerHTML = floater + a.innerHTML
      a.setAttribute('href', 'javascript:;')
      do (menu, action, cm, a) -> a.onclick = ->
        args = a.getAttribute('args')?.split(',') ? []
        menu.vc.hide()
        CodeMirror.commands[action](cm, args)
        
    button.addEventListener("click", ((ev) =>
      ev.preventDefault(); menu.vc.at(ev)
    ), true)
      
module.exports = ContextMenu