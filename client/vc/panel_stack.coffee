# Copyright (C) 2014-5 paul@marrington.net, see /GPL for license
Integrant = require 'vc/Integrant'
resize2 = require 'resize2'
Storage = require 'Storage'

resizer = document.createElement('tr')
resizer.classList.add 'resizer'
resizer.innerHTML = "<td><div></div></td>"

getTD = (tr) ->
  td = tr.firstChild
  while td?.nodeName isnt 'TD'
    break if not (td = td.nextSibling)
  return td

module.exports = class PanelStack extends Integrant
  init: ->
    @storage = new Storage(@opts.name, @opts.vc, default:[])
    for lower, index in @list('resizable')
      upper = lower.previousSibling
      while upper?.nodeName isnt 'TR'
        return if not (upper = upper?.previousSibling)
      tr = resizer.cloneNode(true)
      div = (handle = tr.firstChild).firstChild
      lower.parentNode.insertBefore(tr, lower)
      lower = getTD lower
      upper = getTD upper
      if sizes = @storage.value[index]
        upper.style.height = sizes[0]
        lower.style.height = sizes[1]
      do (index) =>
        resize2 { handle, upper, lower }, (args...) =>
          @storage.save @storage.value[index] =
            [args[0].element.style.height, args[1].element.style.height]
          @emit 'resize', args...