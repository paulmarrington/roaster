# Copyright (C) 2012,13 paul@marrington.net, see /GPL license
url = require 'url'; path = require 'path'; os = require 'os'
http = require 'http'; https = require 'https'
fs = require 'fs'; querystring = require 'querystring'
url = require 'url'; timer = require 'common/timer'
_ = require 'underscore'; dirs = require 'dirs'
events = require 'events'

class Internet extends events.EventEmitter
  constructor: (@base = '') ->
    @retry_for = 5
    # download a file - pausing the stream while it happens
    # internet.download.to(file_path).from url, => next()
    @download =
      from: (@from, next) => @fetch(next); return @download
      to: (@to, next) => @fetch(next); return @download
    # process options as needed
    @_options = {}
    Object.defineProperty @, "options",
      get: => return @_options
      set: (value) =>
        @_options = if value?[0] then value[0] else {}
        @_options.headers ?= {}

  # Abort stream if Internet unavailable
  available: (url..., next) ->
    @once 'connect', (error) => next(error)
    url = if url.length then url[0] else 'http://google.com'
    @send_request 'HEAD', url

  # Post known static data as either a string or url-encoded
  post: (address, data, @options..., on_connect) ->
    if typeof data isnt 'string'
      data = querystring.stringify data
    @options.headers['Content-Length'] = data.length
    @once 'request', => @request.end data
    @once 'connect', on_connect
    @send_request 'POST', address

  # prepare to post a stream of data
  post_stream: (address, @options..., on_request) ->
    @once 'request', on_request
    @send_request 'POST', address

  # put a stream down the http line
  put:  (address, @options..., on_request) ->
    @once 'request', on_request
    @send_request 'PUT', address

  # helper for http GET - returns request object
  get: (address, @options..., on_connect) ->
    @once 'request', => @request.end()
    @once 'connect', on_connect
    @send_request 'GET', address
  # helper for http GET - returns request object
  get_stream: (address, @options..., on_connect) ->
    @once 'connect', on_connect
    @send_request 'GET', address
  # helper to get a JSON response - in-memory so size limited
  get_json: (address, @options..., next) ->
    @once 'request', => @request.end()
    check = (err) => if err then @request?.abort(); next(err)
    @once 'error', check
    @read_response (data) =>
      next null, '' if not data?.length
      try next null, JSON.parse data
      catch error then check data
    @send_request 'GET', address
  # set how many seconds we keep retrying
  retry: (seconds) -> @retry_for = seconds; return @

  fetch: (on_download_complete) ->
    return if not on_download_complete
    console.log "Downloading #{@from}..."
    to = @to
    @get @from, (error) =>
      if error
        console.log error
        console.log error.trace if error.trace
        return on_download_complete error
      dirs.mkdirs path.dirname(to), =>
        writer = fs.createWriteStream to
        @response.on 'end', => writer.end()
        writer.on 'finish', =>
          console.log '...done'
          on_download_complete()
        @response.pipe writer
    @from = @to = ''

  send_request: (method, address) ->
    if not address?.length
      address = @base
    else
      address = address[1..] if address[0] is '/'
      address = "#{@base}/#{address}" if @base?.length
    address = url.parse address, true, true
    # restore the query string - and add any from @options
    query = querystring.stringify _.extend {},
      address.query, @_options.query
    address.path =
      if query.length then "#{address.pathname}?#{query}"
      else address.pathname
    # restore the hash if there is one
    address.path += '#'+address.path if address.hash?.length
    options =
      method: method
      hostname: address.hostname
      path: address.path
      port: address.port
      on_request: ->
    # see if we are http or https
    if address.protocol is 'http:'
      address.port ?= 80; transport = http
    else
      address.port ?= 443; transport = https
      options.rejectUnauthorized = false
      options.agent = new https.Agent(options)
    options.port = address.port
    options[key] = value for key, value of @_options
    @_options = {}
    clock = timer silent:true
    @request = null
    do requesting = =>
      @request?.abort()
      @request = transport.request options, (@response) =>
        @emit 'connect', null, @request, @response
        @removeAllListeners()
      @emit 'request', @request
      @request.on 'error', (error) =>
        if error?.code is 'ECONNREFUSED' and
        clock.total() < @retry_for
          return setTimeout requesting, 500
        options = JSON.stringify options
        error = new Error(
          "#{error?.code} for #{address.href}\n#{options}")
        @emit 'connect', error, @request
        @removeAllListeners()

  # read response into a string for further processing
  read_response: (next) ->
    @once 'connect', (error) ->
      return @emit('error', error) if error
      response_stream = new ResponseStream()
      response_stream.on 'finish', (data) -> next(data)
      @response.pipe response_stream

class ResponseStream extends require('stream').Writable
  constructor: -> @chunks = []
  end: (dat) -> @write(dat); @emit 'finish', @chunks.join('')
  write: (dat) -> @chunks.push dat; return true

module.exports = (args...) -> new Internet(args...)
