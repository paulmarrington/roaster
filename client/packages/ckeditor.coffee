
# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
version = "4.1.1"
pkg = "full"
base = "http://download.cksource.com/CKEditor/CKEditor/CKEditor "
ckurl = "http://download.ckeditor.com"
plugin_dir = "ckeditor/plugins/"
packages =
  ckeditor: "#{base}#{version}/ckeditor_#{version}_#{pkg}.zip|."
  tableresize: "#{ckurl}/tableresize/releases/tableresize_4.1.1.zip|#{plugin_dir}"
  placeholder: "#{ckurl}/placeholder/releases/placeholder_4.1.1.zip|#{plugin_dir}"

toolbarGroups = [
  { name: 'document' }
  { name: 'doctools' }
  { name: 'clipboard', groups: [ 'clipboard', 'undo' ] }
  { name: 'editing', groups: [ 'find', 'selection', 'spellchecker' ] }
  { name: 'forms' }
  { name: 'basicstyles', groups: [ 'basicstyles', 'cleanup' ] }
  { name: 'paragraph', groups: [ 'list', 'indent', 'blocks' ] }
  { name: 'align', groups: ['align', 'bidi'] }
  { name: 'links' }
  { name: 'insert' }
  { name: 'styles' }
  { name: 'colors' }
  { name: 'tools', groups: [ 'mode', 'tools'] }
  { name: 'others' }
  { name: 'about' }
]
toolbarViews =
  Document: 'document,paragraph,align,insert'
  Edit: 'basicstyles,links,styles,colors'
  Form: 'forms,styles,colors'
  View: 'doctools,tools,others,about'

default_options =
  fullPage: true
  allowedContent: true
  browserContextMenuOnCtrl: true
  contentsCss: '/page.stylus'
  scayt_autoStartup: true
  removeButtons: ''
  toolbarGroups: toolbarGroups
  toolbarViews: toolbarViews
  maximize: true
  extraPlugins: 'tableresize,placeholder'

open = (id, options) ->
  options = _.extend {}, default_options, options
  options.removeButtons += ',Maximize' if options.maximize

  roaster.ckeditor.editors[id] = editor = CKEDITOR.replace 'document', options

  editor.toolbarGroupNames = {}
  for group, index in options.toolbarGroups
    editor.toolbarGroupNames[group.name] = index
  [toolbarViews, options.toolbarViews] = [options.toolbarViews, {}]
  options.toolbarViews[view] = list.split(',') for view,list of toolbarViews

  editor.showToolbarGroup = (name) ->
    for group in options.toolbarGroups
      index = editor.toolbarGroupNames[group.name]
      $($('.cke_toolbox span.cke_toolbar', editor.div)[index]).hide()
    for group in options.toolbarViews[name]
      index = editor.toolbarGroupNames[group]
      $($('.cke_toolbox span.cke_toolbar', editor.div)[index]).show()
    $('.cke_editor_tabs a', editor.div).removeClass 'cke_editor_tab_selected'
    $(".cke_editor_tab_#{name}", editor.div).addClass 'cke_editor_tab_selected'
    return false

  editor.once 'instanceReady', ->
    editor.div = $ '.cke_inner', $ editor.container.$
    tab = $ '<div class="cke_editor_tabs"></div>'
    for name in (name for name, items of options.toolbarViews).sort()
      do ->
        tab_name = name
        a = $ "<a class='cke_editor_tab cke_editor_tab_#{name}'>#{name}</a>"
        a.click -> roaster.ckeditor.editors[id].showToolbarGroup(tab_name)
        tab.append a
    editor.div.prepend tab
    editor.showToolbarGroup 'Edit'
    editor.getCommand('maximize').exec() if options.maximize
  return editor

loader = roaster.dependency(packages, '/ext/ckeditor/ckeditor.js')

module.exports = (next) ->
  roaster.ckeditor = {open,editors:{}}
  loader next
