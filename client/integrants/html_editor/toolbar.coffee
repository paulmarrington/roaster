# Copyright (C) 2014 paul@marrington.net, see /GPL for license
class Toolbar
  init: (@host) ->
    
  prepare: ->
    he = @host.walk('html_editor/..')
    @ckelement = he.ckeditor.container.$
    buttons = {'Unprocessed':[]}
    for group, name of @layout
      for button in name
        button = button[1..-1] if button[0] is '!'
        buttons[button] = group: group
    tbx = @ckelement.getElementsByClassName('cke_toolbox')[0]
    elements = (b for b in \
      tbx.getElementsByClassName('cke_button')).concat( \
      c for c in tbx.getElementsByClassName('cke_combo_button'))
    for element in elements
      name = element.title
      name = 'Unprocessed' if not buttons[name]
      buttons[name].element = element
    if buttons['Unprocessed'].length
      console.log "Unknown buttons:",buttons['Unprocessed']
    sep = tbx.getElementsByClassName('cke_toolbar_separator')[0]
    grp = tbx.getElementsByClassName('cke_toolbar')[0]
    cnt = grp.getElementsByClassName('cke_toolgroup')[0]
    cnt.innerHTML = tbx.innerHTML = ''; container = tab = null
    new_container = true
    
    add_tab = (name) ->
      tbx.appendChild tab = document.createElement('span')
      tab.style.display = 'none'
      tab.classList.add "#{name}_buttons", 'tab_buttons'
    add_container = ->
      return if not new_container
      new_container = false
      tab.appendChild  container = cnt.cloneNode()
    add_button = (name, to) ->
      if (button = buttons[name])?.element
        to.appendChild button.element
      else
        console.log "Lost button '#{name}'"
    for group in @groups
      add_tab group
      new_container = true
      for name in @layout[group]
        switch name[0]
          when '-'
            new_container = true
          when '!'
            add_button name[1..-1], tab
            new_container = true
          when '|'
            add_container()
            container.appendChild sep.cloneNode()
          else
            add_container()
            add_button name, container
    
  show: (name) ->
    for tb in @ckelement.getElementsByClassName('tab_buttons')
      tb.style.display = 'none'
    tb = @ckelement.getElementsByClassName("#{name}_buttons")
    tb[0].style.display = null
    
  groups: "Font,Paragraph,Insert,Form,View".split(',')
  
  layout:
    'Font':
      ['Bold','Italic','Underline','Strike Through','Subscript',
       'Superscript','|','Remove Format', 'Text Color',
       'Background Color','!Font Name','!Font Size']
    'Paragraph':
      ['!Formatting Styles','!Paragraph Format',
       'Insert/Remove Numbered List','Insert/Remove Bulleted List',
       '|','Decrease Indent','Increase Indent','|','Block Quote',
       'Create Div Container', '--',
       'Align Left','Center','Align Right','Justify','--',
       'Text direction from left to right',
      'Text direction from right to left','Set language']
    'Insert':
      ['Select All','|','Cut','Copy','Paste','|',
       'Paste as plain text', 'Paste from Word','--',
       'Undo','Redo','--','Link','Unlink', 'Anchor','--',
       'Templates','|','Table','|','Placeholder',
       'Image','Flash','Insert Horizontal Line','Smiley',
       'Insert Special Character','Insert Page Break for Printing',
       '|','IFrame']
    'Form':
      ['Form','--','Checkbox','Radio Button','|','Text Field',
       'Textarea','Selection Field','|','Button','Image Button',
       '--','Hidden Field']
    'View':
      ['Maximize','|','Preview','Print','--','Find','Replace','--',
      'Spell Check As You Type','--'
      'Source','|','Show Blocks','--','About CKEditor']
    'Unused':
      ['Save','New Page']
  
module.exports = Toolbar