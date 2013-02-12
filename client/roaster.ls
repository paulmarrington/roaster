# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

# Simple effective asynchronous module requirements for the browser.

# Dependencies are only loaded once - the first time they are referenced. Afterwards
# the same in-memory instance is used. By using 'depends' when the information is
# referenced in a parent module means that code is loaded on demand - giving a responsive
# UI without resorting to combining script files.

# If run on the uSDLC-node-server, translation to js from coffeescript, etc is transparent.
# This means any supported language will work (coffee-script, live-script, clojure-script, etc)

# In the example below script 'a' depends on script 'b'. The closure is only run
# after script 'b' was loaded. Script 'b' in turn relies on script 'c'. In the end
# the log is only written to and the value checked after scripts a, b and c are all
# loaded.

# #a.coffee:
# depends 'b', (b) ->
#   console.log b.name
#   throw 'wrong' if b.value isnt 1

#   depends 'c', (c) ->
#     throw 'wrong' if c() isnt 2

#     depends.forceReload 'c'
#     depends 'c', (c) ->
#       throw 'wrong' if c isnt 1 # reset as c.js is reloaded

# #b.coffee
# ->
#   depends 'c', (c) ->
#     return
#       name: "bee"
#       value: c()

# #c.js
# function() {
#   counter = 1
#   return function() {counter++}
# }

module.exports = (exchange) ->
  exchange.respond.js ->
    window.slice$ = window.__slice = [].slice
    window.__bind = (fn, me) -> return -> return fn.apply(me, arguments)
    window.bind$ = (obj, key, target) ->
      return -> return (target || obj)[key].apply(obj, arguments)

    window.roaster = 
      depends: (url, next) ->
        # see if we are loaded and ready to go
        return next ...dependency if dependency = roaster.cache[url]
        # see if we are in the process of loading
        return roaster.loading[url].push(next) if roaster.loading[url]
        # ok, we are going to need to kick of a synchronous load
        roaster.loading[url] = [next]

        roaster.script-loader url, ->
          dependency = roaster.cache[url]
          callbacks = roaster.loading[url]
          while callback = callbacks.pop()
            callback ...dependency if callback
          delete roaster.loading[url]

      script-loader: (url, next) ->
        return next! if roaster.cache[url]
        script = document.createElement("script")
        script.type = "text/javascript"
        script.async = "async"
        if script.readyState # IE
          script.onreadystatechange = ->
            if script.readyState == "loaded" || script.readyState == "complete"
              script.onreadystatechange = null;
              roaster.cache[url] ?= []
              next();
        else # Other browsers
          script.onload = ->
            roaster.cache[url] ?= url:url
            next()

        script.src = url
        document.getElementsByTagName("head")[0].appendChild(script)

      data-loader:  (url, next) ->
        request = new XMLHttpRequest()
        request.open 'GET', url, true
        request.onreadystatechange = (event) ->
          return if request.readyState isnt 4
          switch request.status
            | 200 => next null, request.responseText
            | otherwise => next request.statusText
        request.send null

      scriptIndex: 0
      cache: {}
      loading: {}

      # # Use depends.ready to run a callback when all listed dependencies are loaded.
      # # Value added depends will return the dependency if we know it has loaded.
      # depends.ready = (urls..., callback) ->
      #   unloaded = (url for url in urls when depends.cache[url])
      #   to_load = unloaded.length
      #   return callback() if to_load is 0

        # aggregate_callback = -> callback() if --to_load is 0
        # depends url, aggregate_callback for url in unloaded

      # Use forceReload if a module source has changed (edited on browser, for example)
      force-reload: (url) -> delete roaster.cache[url]
      
    window.depends = roaster.depends
    # step() is so often used with depends that it makes sense to load it the
    # first time it is called
    window.step = (...steps) ->
      roaster.depends '/client/step.ls', (error, step) ->
        step ::=
          # wrapper for dependencies that have asynchronous actions during
          # initialisation. Only for client. Contents need to be
          # module.exports = (error, next) -> init code
          # can include non-asynchronous that return anything, but they
          # must not return a function with two parameters or it will be
          # run.
          depends: (...urls) ->
            # after load we call the result with a next action parameter
            @parallels-setup()
            for url in urls => roaster.depends url, @parallel()
          # wrapper for library JS files that do not work on the global
          # name-space specifically. It is the same as  <script> tag.
          library: (...urls) ->
            # after load we call the result with a next action parameter
            @parallels-setup()
            for url in urls => roaster.script-loader url, @parallel()

          # load static data asynchronously
          data: (...urls) ->
            for url in urls then roaster.data-loader url, @parallel()
        
        window.step = step
        step ...steps

    window.server-status =
      start-time: Number.MAX_VALUE
      debug-mode: false

    get-server-status = ->
      roaster.data-loader '/server/http/status.server.ls', (error, data) ->
        # return setTimeout(get-server-status, 5000) if error or not data
        try
          last-server-status = window.server-status
          window.server-status = JSON.parse data
          if server-status.debug-mode
            if window.server-status.start-time > last-server-status.start-time
              window.location.href = window.location.href
              return
            request = new XMLHttpRequest()
            request.open 'GET', '/server/http/alive.server.ls', true
            request.onreadystatechange = (event) ->
              if request.readyState is 4
                setTimeout get-server-status, 1000
            request.send null
        catch
          setTimeout get-server-status, 1000

    get-server-status!
