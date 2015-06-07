# Copyright (C) 2014 paul@marrington.net, see /GPL for license

module.exports = class Tabs
  prepare: ->
    @view = @vc.get_vc_for('tabs')
    @view.on 'selected', (tab) =>
      @vc.toolbar.show tab.getAttribute('name')

  select: (tab) -> @view.select tab

  is_selected: (tab) -> @view.is_selected tab
