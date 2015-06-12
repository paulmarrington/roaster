# Copyright (C) 2015 paul@marrington.net, see /GPL license

module.exports = class Select
  element: (type) ->
    selection = @vc.ed.getSelection()
    selectedElement = selection.getSelectedElement()
    if selectedElement?.is type
      selection.selectElement(selectedElement)
      return selectedElement

    if range = @range()
      range.shrink( CKEDITOR.SHRINK_TEXT )
      path = @vc.ed.elementPath( range.getCommonAncestor() )
      if type
        selectedElement = path.contains( type, 1 )
      else
        selectedElement = path.lastElement
      if selectedElement
        selection.selectElement selectedElement
        return selectedElement
    return null

  beginning: ->
    range = @vc.ed.createRange()
    range.moveToPosition( range.root, CKEDITOR.POSITION_AFTER_START )
    @vc.ed.getSelection().selectRanges( [ range ] )

  end: ->
    range = @vc.ed.createRange()
    range.moveToPosition( range.root, CKEDITOR.POSITION_BEFORE_END )
    @vc.ed.getSelection().selectRanges([range])
    return range

  before: (range) -> @previous null, any_element_parameter

  after: (range) -> @next null, any_element_parameter

  next: (node_name, selector = node_name_comparator) ->
    return @goto selector(node_name),  'next',
    CKEDITOR.POSITION_AFTER_START, (range) =>
      range.setEndAt(@vc.ed.editable(), CKEDITOR.POSITION_BEFORE_END)

  previous: (node_name, selector = node_name_comparator) ->
    return @goto selector(node_name),  'previous',
    CKEDITOR.POSITION_BEFORE_END, (range) =>
      range.setStartAt(@vc.ed.editable(), CKEDITOR.POSITION_AFTER_START)
      @vc.ed.getSelection().selectRanges([range])

  here: (setter) ->
    if setter
      @vc.ed.getSelection().selectRanges([setter.range])
      return setter
    range = @range()
    node = range.startContainer
    return {range, node}

  restore_caret: (action) ->
    range = @range()
    result = action.call(@)
    @restore_range(range)
    return result

  restore_range: (range) ->
    @vc.ed.getSelection().selectRanges([range])

  range: ->
    if not range = @vc.ed.getSelection().getRanges()[0]
      range = @end()
    return range

  goto: (selector, dir, end, position) ->
    range = @range()
    range.collapse( true )
    position(range)
    result = null
    walker = new CKEDITOR.dom.walker( range )
    walker.guard = (node, exiting) =>
      return true if not selected = selector(node)
      range.moveToPosition node, end
      @vc.ed.getSelection().selectRanges([range])
      result = {range, node, selected}
      return false
    while node = walker[dir]() then
    return result

any_element_parameter = -> return -> true

node_name_comparator = (node_name) ->
  [node_name, classes...] = node_name.split('.')
  if not classes # next occurence of a node
    return (node) -> node.$.nodeName.toLowerCase() == node_name
  return (node) -> # node.class1.class2 ...
    return false if node.$.nodeName.toLowerCase() != node_name
    for cls in classes
      return false if not node.$.classList.contains(cls)
    return true
