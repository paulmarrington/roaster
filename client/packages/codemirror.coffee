# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license

roaster.codemirror_base = base = '/ext/codemirror/Codemirror-master'
addon = (type) -> return "#{base}/addon.#{type}.concat?
exclude=(standalone.js$|_test.js$|pig-hint.js)"
keymap = "#{base}/keymap.js.concat"

module.exports = (next) -> queue ->
  @restart_timer(300)
  @package 'coffeelint', 'jshint', 'jsonlint', @next
  @queue -> roaster.dependency(
    codemirror: 'https://codeload.github.com/marijnh'+
      '/CodeMirror/zip/master|codemirror'
    "#{base}/lib/codemirror.css"
    "#{base}/lib/codemirror.js"
    "#{base}/mode/coffeescript/coffeescript.js"
    "#{base}/mode/javascript/javascript.js"
  )(@next ->)
  @css addon('css')
  @script_loader addon('js'), 'client', @next
  @script_loader keymap, 'client,library', @next
  @css "#{base}/theme.css.concat"
  @queue @next next

# module.exports = (next) ->
#   steps(
#     ->  @long_operation()
#     ->  @package 'coffeelint', 'jshint', 'jsonlint'
#     ->  @asynchronous roaster.dependency(
#           codemirror: 'https://codeload.github.com/marijnh'+
#             '/CodeMirror/zip/master|codemirror'
#           "#{base}/lib/codemirror.css"
#           "#{base}/lib/codemirror.js"
#           "#{base}/mode/coffeescript/coffeescript.js"
#           "#{base}/mode/javascript/javascript.js"
#         )(@next)
#     ->  roaster.request.css addon('css')
#     ->  roaster.script_loader addon('js'), 'client', @next
#     ->  roaster.script_loader keymap, 'client,library', @next
#     ->  roaster.request.css "#{base}/theme.css.concat"
#     ->  next()
#     )
