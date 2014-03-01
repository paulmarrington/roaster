# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
dependency = require 'dependency'

roaster.codemirror_base = base =
  '/ext/codemirror/CodeMirror-master'
addon = (type) -> return "#{base}/addon.#{type}.concat?
exclude=(standalone.js$|_test.js$|pig-hint.js)"
keymap = "#{base}/keymap.js.concat"

module.exports = (next) ->
  roaster.packages 'coffeelint', 'jshint', 'jsonlint', ->
    dependency(
      codemirror: 'https://codeload.github.com/marijnh'+
        '/CodeMirror/zip/master|codemirror'
      "#{base}/lib/codemirror.css"
      "#{base}/lib/codemirror.js"
      "#{base}/mode/coffeescript/coffeescript.js"
      "#{base}/mode/javascript/javascript.js"
    ) ->
      roaster.request.css addon('css')
      roaster.script_loader addon('js'), 'client', ->
        roaster.script_loader keymap, 'client,library', ->
          roaster.request.css "#{base}/theme.css.concat"
          next()
