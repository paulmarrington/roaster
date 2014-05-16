integrant_cache = {}

integrant =
  mvc:   mvc
  style: (element, styles) ->
    element.style[k] = v for k, v of styles
  append: (opts = {}) ->
    @list ?= []
    @host.appendChild panel = @template.cloneNode(true)
    @list.push panel
    panel.opts = opts
    @style panel, opts.style
    @prepare? panel
    return panel
  add: (items) ->
    @[name] = @append(opts) for name, opts of items
  select: (item) ->
    console.log item+"="+@[item].innerHTML+" from "+@selected?.innerHTML
    @selection @selected, false if @selected
    @selection @selected = @[item], true
      
module.exports = mvc = (name, host, opts, ready) ->
  if not ready and opts instanceof Function
    ready = opts; opts = {}
  host = host.host if host.host # element or integrant works
  activate = ->
    return false if not (module = integrant_cache[name])
    host.innerHTML = module.html
    host.classList.add name
    instance = new module(host, mvc, opts...)
    instance.host ?= host; instance.opts ?= opts[0]
    instance.template ?= instance.host.firstElementChild
    instance[k] = v for k, v of integrant
    ready null, instance
    return true
  return if activate()
  
  if name[0] is '/'
    base = ''
    name = name[1..-1]
  else
    base = "client/integrants/"
    
  module_html = null
  require.css "#{base}#{name}.css"
  require.data "#{base}#{name}.html", (error, html) ->
    if integrant_cache[name]
      integrant_cache[name].html = html
      activate()
    else
      module_html = html # waiting on script
  module_name = "#{base}#{name}"
  require module_name, (the) ->
    exports = the[module_name]
    exports.html = module_html
    integrant_cache[name] = exports
    activate() if module_html