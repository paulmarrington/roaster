# Copyright (C) 2014 paul@marrington.net, see /GPL for license
action = (tab, select) ->
  return unless select
  tab.click()

class Tabs
  init: (@host) ->
    
  picture:
    mvc: 'tab_view'
    cargo:
      Font:      {}
      Paragraph: {}
      Insert:    {}
      Form:      {}
      View:      {}

module.exports = Tabs
