module.exports = (exchange) ->
  exchange.respond.client ->
    load_requires = ->
      @service '/scratch/dep_sync.coffee'

    check_requires = ->
      console.log "dep_sync=#{@dep_sync} (should be 'dep-sync result')"

    load_libraries = ->
      # test out libraries that are synchronous js files that load in parallel
      window.libraries_test = []
      @requires '/scratch/l1.js', '/scratch/l2.js','/scratch/l3.js'

    check_libraries = ->
      console.log window.libraries_test
      console.log "Expecting 'l1 loaded, l2 loaded, l3 loaded'"

    check_libraries_reload = ->
      console.log window.libraries_test
      console.log "Expecting empty list since already loaded"

    load_parallel_requires = ->
      @parallel(
        -> @requires '/scratch/dep_async.coffee'
        -> @requires '/scratch/dep_async4.coffee')

    check_parallel_requires = ->
      console.log "@parallel dep_async=#{@dep_async}, dep_async4=#{@dep_async4}"
      console.log "Expecting two x 'dep-async[-n] result"

    load_data = ->
      @data '/scratch/run', '/scratch/l1.js'

    check_data_load = ->
      console.log "run=#{@run?.length}, l1=#{@l1?.length}"
      console.log "Async data load = both should have non-zero lengths"

    load_faye = -> @requires '/client/faye.coffee'

    instantiate_faye = -> @faye @next (@faye) =>

    start_faye_server_script = ->
      @service '/scratch/test_faye.server.coffee'
      console.log "Expecting 'test-faye.server.coffee ran' on client console"
      console.log "and 3 'Server' type messages on the server console"

    subscribe = ->
      @faye.subscribe '/channel/on-client', (message) -> console.log message.text
      console.log "Expect 'from server to client' on client console"

    publish = ->
      go = =>
        console.log "Expecting 'from client to server' on server"
        @faye.publish '/channel/on-server', text: 'from client to server'
        console.log "Expecting 'from client to client' on client"
        @faye.publish '/channel/on-client', text: 'from client to client'
      setTimeout go, 1000


    steps(
      load_requires
      check_requires

      load_libraries
      check_libraries

      load_libraries
      check_libraries_reload

      load_parallel_requires
      check_parallel_requires

      load_data
      check_data_load

      load_faye
      instantiate_faye
      start_faye_server_script
      subscribe
      publish
    )
