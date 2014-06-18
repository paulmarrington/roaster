# Copyright (C) 2014 paul@marrington.net, see /GPL for license
action = (tab, select) ->
  return unless select
  tab.click()

class Tabs  
  init: (@integrant, ready) -> ready()
  
  connect: (ready) -> ready()
  
  definition:
    integrant: 'tab_view'
    host_class: 'td'
    action: action
    named_content: true
    add:
      Font:      {}
      Paragraph: {}
      Insert:    {}
      Form:      {}
      View:      {}

module.exports = Tabs
