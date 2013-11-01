# Copyright (C) 2013 paul@marrington.net, see /GPL for license
roaster.Queue = require '/common/queue.coffee'
module.exports = roaster.queue = roaster.Queue.instance
roaster.queue.mixin = roaster.Queue.mixin

roaster.Queue::depends = (domain, modules, next) ->
  @restart_timer(300)
  console.log modules if @tracing
  roaster.request.depends domain, modules, (error, refs) =>
    @[n] = v for n, v of refs
    #roaster.queue.mixin(refs)
    next()
    
roaster.queue.mixin
  requires: (modules..., next) ->
    @depends 'client', modules, next
  package: (packages..., next) ->
    @depends 'package', packages, next
  libraries: (libraries..., next) ->
    @depends 'client,library', libraries, next
  service: (scripts..., next) ->
    @depends 'server', scripts, next
  data: (urls..., next) ->
    @restart_timer(300)
    console.log urls if @tracing
    roaster.request.data_loader urls, (err, refs) =>
      @[n] = v for n, v of refs
      next(err, refs)
  json: (urls..., next) ->
    @restart_timer(300)
    console.log urls if @tracing
    roaster.request.data_loader urls, (err, refs) =>
      @[n] = refs[n] = JSON.parse(v) for n, v of refs
      next(err, refs)
  dependency: (packages) ->
    url = roaster.add_command_line(
      '/server/http/dependency.coffee', packages)
    roaster.request.json url, @next (data) =>
      for key, value of data
        if not value
          @error = "No package #{packages[key]}"
  script_loader: roaster.script_loader
  css: roaster.request.css
