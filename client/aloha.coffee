# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
aloha = null; waiting = []

get = (next) -> waiting.push(next)

steps(
  ->  @dependency aloha:
        'http://aloha-editor.org/builds/stable/alohaeditor-0.23.3-cdn.zip'
  ->  @requires(
        '/ext/aloha/css/aloha.css'
        '/ext/aloha/lib/require.js'
        '/ext/aloha/lib/vendor/jquery-1.7.2.js'
        '/ext/aloha/aloha.js'
      )
  ->  aloha = @aloha; get = (next) -> next(aloha)
  ->  next(aloha) for next in waiting
)

module.exports = (next) -> get(next)
