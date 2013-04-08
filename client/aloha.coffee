# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
aloha = null; waiting = []

get = (next) -> waiting.push(next)

plugins = "
common/ui,common/format,common/highlighteditables,common/link,
common/abbr,common/align,common/block,common/characterpicker,
common/commands,common/contenthandler,
common/horizontalruler,common/image,common/list,common/paste,
common/table,common/undo,extra/browser,extra/captioned-image,
extra/cite,extra/comments,extra/draganddropfiles,
extra/formatlesspaste,extra/headerids,extra/linkbrowser,
extra/metaview,extra/numerated-headers,extra/ribbon,
extra/sourceview,extra/toc,extra/validation"

steps(
  ->  @dependency
        aloha:
          'http://aloha-editor.org/builds/stable/alohaeditor-0.23.3-cdn.zip'
        'aloha/plugins/community/colorselector':
          'https://github.com/deliminator/Aloha-Plugin-Colorselector/archive/master.zip'
  ->  @libraries(
        '/ext/aloha/css/aloha.css'
        '/ext/aloha/lib/require.js'
        '/ext/aloha/lib/vendor/jquery-1.7.2.js'
        "/ext/aloha/lib/aloha.js#data-aloha-plugins=#{plugins}"
      )
  ->  aloha = @aloha; get = (next) -> next(aloha)
  ->  $('div').aloha()
  ->  next(aloha) for next in waiting
)

module.exports = (next) -> get(next)
