# Copyright (C) 2014 paul@marrington.net, see /GPL for license

class Tabs
  init: (@host) ->
    tabs = @host.walk('tabs').picture.cargo
    toolbar = @host.integrant.toolbar
    for name, data of tabs
      do (name, data) => data.select = => toolbar.show(name)
  

module.exports = Tabs
