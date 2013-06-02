# Copyright (C) 2012,13 paul@marrington.net, see GPL for license
url = require 'url'; path = require 'path'; os = require 'os'
http = require 'http'; https = require 'https'; fs = require 'fs'
querystring = require 'querystring'; url = require 'url'
timer = require 'common/timer', _ = require 'underscore'

class Internet
  constructor: (@base = '') ->
    @retry_for = 5
    # download a file - pausing the stream while it happens
    @download = # internet.download.to(file_path).from url, => next()
      from: (@from, next) => @download_now(next); return @download
      to: (@to, next) => @download_now(next); return @download
    # process options as needed
    @_options = {}
    Object.defineProperty @, "options",
      get: => return @_options
      set: (value) =>
        @_options = if value?.length and value[0] then value[0] else {}
        @_options.headers ?= {}

  # Abort stream if Internet unavailable - require(internet).available(gwt)
  available: (next) ->
    @send_request 'HEAD', 'http://google.com', (error) =>
      if error then @request.end() else next()

  # Post known static data as either a string or url-encoded
  post: (address, data, @options..., on_response) ->
    data = querystring.stringify data if typeof data isnt 'string'
    @options.headers['Content-Length'] =  data.length
    @options.on_request = => @request.end data
    @send_request('POST', address, on_response)

  # prepare to post a stream of data
  post_stream: (address, @options..., on_response) ->
    @send_request('POST', address, on_response)

  # put a stream down the http line
  put:  (address, @options..., on_response) ->
    @send_request('PUT', address, on_response)

  # helper for http GET - returns request object
  get: (address, @options..., on_response) ->
    @options.on_request = => @request.end()
    @send_request 'GET', address, on_response
  # helper for http GET - returns request object
  get_stream: (address, @options..., on_response) ->
    @send_request 'GET', address, on_response
  # helper to get a JSON response - in-memory so size limited
  get_json: (address, @options..., next) ->
    @options.on_request = => @request.end()
    check = (err) => if err then @request?.abort(); next(err)
    @send_request 'GET', address, (error) =>
      check error
      @read_response (data) =>
        next null, '' if not data.length
        try next null, JSON.parse data
        catch error then check data
  # set how many seconds we keep retrying
  retry: (seconds) -> @retry_for = seconds; return @

  download_now: (on_download_complete) ->
    return if not on_download_complete
    console.log "Downloading #{@from}..."
    to = @to
    @get @from, (error) =>
      if error
        console.log error
        console.log error.trace if error.trace
        return on_download_complete error
      writer = fs.createWriteStream to
      @response.on 'end', =>
        console.log '...done';
        writer.end()
        on_download_complete()
      @response.pipe writer
    @from = @to = ''

  send_request: (method, address, on_connection) ->
    if not address?.length
      address = @base
    else
      address = address[1..] if address[0] is '/'
      address = "#{@base}/#{address}" if @base?.length
    address = url.parse address, true, true
    # restore the query string - and add any from @options
    query = querystring.stringify _.extend {}, address.query, @_options.query
    address.path =
      if query.length then "#{address.pathname}?#{query}" else address.pathname
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
        on_connection(null, @request, @response)
      options.on_request @request
      @request.on 'error', (error) =>
        if error?.code is 'ECONNREFUSED' and clock.total() < @retry_for
          return setTimeout requesting, 500
        on_connection error, @request

  # read response into a string for further processing
  read_response: (next) ->
    data = []
    @response.on 'data', (chunk) -> data.push chunk
    @response.on 'end', => next data.join ''

module.exports = (args...) -> new Internet(args...)
