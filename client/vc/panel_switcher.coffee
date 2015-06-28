# Copyright (C) 2014 paul@marrington.net, see /GPL for license
Integrant = require 'vc/Integrant'

module.exports = class PanelSwitcher extends Integrant
  init: ->
#     if not @child('container')
#       @host.appendChild @container = @template('container')
#       while @host.children.length > 1
#         @container.appendChild @host.firstChild
    @initialisers_for_select()

  add: (name, attributes = {}, ready = ->) ->
    super name.replace(/\W+/g,'_'), attributes, ready
