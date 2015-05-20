# Copyright (C) 2014 paul@marrington.net, see /GPL for license
class Toolbar
  prepare: (cke) ->
    @ckelement = cke.container.$
    @tbx = @ckelement.getElementsByClassName('cke_toolbox')[0]
    tabs = []
    @sep = @tbx.getElementsByClassName('cke_toolbar_separator')[0]
    grp = @tbx.getElementsByClassName('cke_toolbar')[0]
    @cnt = grp.getElementsByClassName('cke_toolgroup')[0]
    @groups = {}
    
    for group, class_names of @layout
      tabs.push @_add group
      @populate group, class_names
    
    # sweep for unused buttons/combos
    for el in @tbx.getElementsByClassName('cke_button')
      console.log "Unused button", el.classList
    for el in @tbx.getElementsByClassName('cke_combo')
      console.log "Unused combo", el.classList
      
    @tbx.innerHTML = ''
    @tbx.appendChild tab for tab in tabs
    return
    
  add: (group) ->
    @tbx.appendChild tab = @_add group
    return tab

  _add: (group) ->
    @groups[group] = tab = document.createElement('span')
    tab.style.display = 'none'  
    tab.classList.add "#{group}_buttons", 'tab_buttons'
    return tab
    
  populate: (group, class_names) ->
    tab = @groups[group]
    container = null; new_container = true
    add_container = =>
      return if not new_container
      new_container = false
      tab.appendChild container = @cnt.cloneNode()
                   
    add_button = (name, to) =>
      name = "cke_#{name}"
      if el = @tbx.getElementsByClassName(name)?[0]
        to.appendChild el
      else
        console.log "Lost button '#{name}'"
        
    for class_name in class_names
      switch class_name[0]
        when '-'
          new_container = true
        when '!'
          add_button "combo__#{class_name[1..-1]}", tab
          new_container = true
        when '|'
          add_container()
          container.appendChild @sep.cloneNode()
        else
          add_container()
          add_button "button__#{class_name}", container
                   
  show: (name) ->
    for tb in @ckelement.getElementsByClassName('tab_buttons')
      tb.style.display = 'none'
    tb = @ckelement.getElementsByClassName("#{name}_buttons")
    tb[0].style.display = null
    
  layout:
    'Font':
      ['bold','italic','underline','strike','subscript',
       'superscript','code','|','removeformat',
       'textcolor',
       'bgcolor','!font','!fontsize'
       ]
    'Paragraph':
      ['!styles','!format',
       'numberedlist','bulletedlist',
       '|','outdent','indent','|','blockquote','--',
       'justifyleft','justifycenter','justifyright',
       'justifyblock']
    'Edit':
      ['selectall','|','cut','copy','paste','|',
       'pastetext', 'pastefromword','--',
       'undo','redo','--','bidiltr','bidirtl','language']
    'Insert':
      ['link','unlink', 'anchor','--',
       'templates','|','creatediv','table','leaflet','|',
        'codesnippet','createplaceholder',
       'image','flash','pagebreak','horizontalrule',
        'smiley','specialchar','|','iframe']
    'Form':
      ['form','--','checkbox','radio','|','textfield',
       'textarea','select','|','button','imagebutton',
       '--','hiddenfield']
    'View':
      ['maximize','|','preview','print','--',
      'find','replace','--','scayt','--'
      'source','|','showblocks','--','about']
    'Unused':
      ['newpage'] # did include 'save'
module.exports = Toolbar