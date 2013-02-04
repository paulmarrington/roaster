step(
  # if the dependant does not do anything asynchronous during init
  # then we can call depends directly
  ()->
    depends '/scratch/dep-sync.coffee', @
  (error, dep_sync) ->
    console.log "dep_sync=#{dep_sync}"

    # if a dependency does async stuff during init it needs to be
    # wrapped in a function and that function called
    depends '/scratch/dep-async.coffee', @
  (error, dep_async) ->
    dep_async null, @

  (error, dep_async2) ->
    console.log "dep_async in-line=#{dep_async2}"

    # As a shorthand function use @depends. This approach also has then
    # benefit of loading more than one dependency in parallel - and passing
    # back all the results
    @depends '/scratch/dep-async.coffee',
      '/scratch/dep-async4.coffee', '/scratch/dep-sync.coffee'
  (error, dep_async3, dep_async4, dep_sync) ->
    console.log "@depends dep_async3=#{dep_async3}, dep_async4=#{dep_async4}, dep_sync=#{dep_sync}"

    # test out libraries that are synchronous js files that load in parallel
    @depends '/scratch/l1.coffee', '/scratch/l2.coffee','/scratch/l3.coffee'
  () ->
    console.log window.libraries_test
    @depends '/scratch/l1.coffee', '/scratch/l2.coffee','/scratch/l3.coffee'

    # Now we need to test what happens when we call depends/libraries on
    # previously loaded code
    window.libraries_test = []
  () ->
    console.log window.libraries_test

    @parallel(
      -> depends('/scratch/dep-async.coffee', @)
      -> depends('/scratch/dep-async4.coffee', @))
  # (error, dep_async5, dep_async6) ->
  #   dep_async5 null, @parallel()
  #   dep_async6 null, @parallel()
  (error, dep_async5, dep_async6) ->
    console.log "@parallel dep_async5=#{dep_async5}, dep_async6=#{dep_async6}"
    #Check async loading of data
    @data '/scratch/run', '/scratch/l1.coffee'
  (error, run, l1) ->
    console.log "error=#{error}"
    console.log "run=#{run.length}"
    console.log "l1=#{l1.length}"

    @depends '/client/faye.ls'
  (error, @faye) ->
    depends.scriptLoader '/scratch/test-faye.server.coffee', @
  ->
    console.log "Client: subscribe to '/channel/on-client'"
    @faye.subscribe '/channel/on-client', (message) -> console.log message.text
    publish = =>
      console.log "Client: publish to '/channel/on-server'"
      @faye.publish '/channel/on-server', text: 'from client to server'
      console.log "Client: publish to '/channel/on-client'"
      @faye.publish '/channel/on-client', text: 'from client to client'
    setTimeout publish, 1000
)
