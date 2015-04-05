# Copyright (C) 2015 paul@marrington.net, see /GPL for license
          
instance_index = 0

class Open
  editor: (@container) ->
    CodeMirror.modeURL =
      '/ext/codemirror/CodeMirror-master/mode/%N/%N.js'
    @vc.editor = CodeMirror @container, @options()
    @vc.editor.id = "codemirror_#{++instance_index}"

    in_autocomplete = allow_autocomplete = false

    @vc.editor.on 'change', (cm, change) =>
      return if in_autocomplete
      # trigger auto-complete list on typing
      return if @vc.editor.somethingSelected()
      cursor = @vc.editor.doc.getCursor()
      line = @vc.editor.doc.getLine(cursor.line)
      if cursor.ch and allow_autocomplete
        if line[cursor.ch - 1].match(/\w/)
          clearTimeout @save_timer
          in_autocompleten = true
          CodeMirror.showHint(cm)
          cm.on 'endCompletion', =>
            in_autocomplete = false

    @vc.editor.on 'keydown', (cm, event) ->
      allow_autocomplete = false

    @vc.editor.on 'keypress', (cm, event) ->
      char_code = event.which ? event.keyCode
      ch = String.fromCharCode(char_code)
      allow_autocomplete = true if ch.match(/\w/)
        
  options: ->
    return @_options if @_options
    if @_options = localStorage.CodeMirror_options
      @_options = JSON.parse(options)
    else
      @_options =
        lineNumbers:        true
        foldGutter:         true
#        gutters:            ["CodeMirror-lint-markers",
#                             "CodeMirror-foldgutter"]
        lint:               true
        matchBrackets:      true
        autoCloseBrackets:  true
        matchTags:          true
        showTrailingSpace:  true
        inputStyle:         "contenteditable"
        autofocus:          true
        dragDrop:           false
        cursorScrollMargin: 5
        scrollbarStyle:     'overlay'
        extraKeys:
          'Cmd-Left':         'goLineStartSmart'
          'Ctrl-Q':           'fold_at_cursor'
          'Ctrl-Space':       'autocomplete'
          'Ctrl-/':           'toggleComment'
          'Ctrl-<':           'goColumnLeft'
          'Ctrl->':           'goColumnRight'
          'Ctrl-Shift-F':     'clearSearch'
          # toMatchingTag appears to only work for XML
          #'Ctrl-=':           'toMatchingTag'
          'Alt-S':            'view_source'
          'Ctrl-`':           'insertSoftTab'
          'Shift-Ctrl-`':     'insertTab'
          'Ctrl-,':           'delLineLeft'
          'Ctrl-.':           'killLine'
          'Shift-Ctrl-,':     'delWrappedLineLeft'
          'Shift-Ctrl-.':     'delWrappedLineRight'
          'Ctrl-9':           'delWordBefore'
          'Ctrl-0':           'delWordAfter'
          'Ctrl-6':           'transposeChars'
          'Ctrl-Left':        'goWordLeft'
          'Ctrl-Right':       'goWordRight'
          'Ctrl-Home':        'goLineLeft'
          'Ctrl-Shift-Home':  'goLineLeftSmart'
          'Ctrl-End':         'goLineRight'
     
module.exports = Open