# Copyright (C) 2014 paul@marrington.net, see /GPL for license

class Tabs
  prepare: ->
    tabs = @vc.get_vc_for('tabs')
    tabs.on 'selected', (tab) =>
      @vc.toolbar.show tab.getAttribute('name')
    
module.exports = Tabs