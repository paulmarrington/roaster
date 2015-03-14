# Copyright (C) 2013-5 paul@marrington.net, see /GPL for license
pkgs =
  codemirror: 'https://codeload.github.com/marijnh'+
    '/CodeMirror/zip/master|codemirror'
base = '/ext/codemirror/CodeMirror-master'
libs = [
  "#{base}/lib/codemirror.css"
  "#{base}/lib/codemirror.js"
  "#{base}/mode/coffeescript/coffeescript.js"
  "#{base}/mode/javascript/javascript.js"
]

module.exports = (loaded) ->
  require.packages 'coffeelint', 'jshint', 'jsonlint', ->
    require.dependency pkgs, libs..., ->
      require.cache['../../lib/codemirror'] = CodeMirror
      addon = (type) -> return "#{base}/addon.#{type}.concat?"+
        "exclude=(standalone\.js|_test\.js|pig-hint\.js|"+
        "\.node\.js|merge\.js)"
      require.css addon 'css'
      console_saver = window.console
      require.script addon('js'), ->
        window.console = console_saver # 'cause tern replaces it
        require.script "#{base}/keymap.js.concat", ->
          require.css "#{base}/theme.css.concat"
          loaded()