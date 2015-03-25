# Copyright (C) 2015 paul@marrington.net, see /GPL for license
class Compile
  constructor: ->
    
  coffee: (source) ->
    return null if not CoffeeScript
    source = CoffeeScript.compile(source, bare:true)
    return source: source, type: 'javascript'
    
  code: (source, options) ->
    compiler = @[@vc.ext]
    return compiler?(source)
    
module.exports = Compile