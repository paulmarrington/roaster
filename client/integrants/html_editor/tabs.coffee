# Copyright (C) 2014 paul@marrington.net, see /GPL for license

class Tabs
  init: (@host) ->
    tab_list = @host.walk('tabs').picture.cargo
    toolbar = @host.integrant.toolbar
    for name, data of tab_list
      do (name, data) => data.select = => toolbar.show(name)
    
module.exports = Tabs