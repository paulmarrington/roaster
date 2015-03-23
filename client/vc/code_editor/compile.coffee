# Copyright (C) 2015 paul@marrington.net, see /GPL for license
class Compile
  constructor: ->
    
  coffee: (source) ->
    return null if not CoffeeScript
    source = CoffeeScript.compile(source, bare:true)
    return source: source, type: 'js'
    
  code: (source, options) ->
    mode = @vc.getOption 'mode'
    compiler = @[mode]
    return compiler?(source)
    
module.exports = Compile