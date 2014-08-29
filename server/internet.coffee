# Copyright (C) 2012,13 paul@marrington.net, see /GPL license
url = require 'url'; path = require 'path'; os = require 'os'
http = require 'http'; https = require 'https'
fs = require 'fs'; querystring = require 'querystring'
url = require 'url'; timer = require 'common/timer'
clone = require 'clone'; dirs = require 'dirs'
events = require 'events'; streams = require 'streams'
files = require 'files'

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
  post: (address, content, @options..., on_complete) ->
    if typeof content isnt 'string'
      content = querystring.stringify content
    @options.headers['Content-Length'] = content.length
    @once 'request', => @request.end content
    @read_response(on_complete)
    @send_request 'POST', address
    
  post_json: (address, object, options..., on_complete) ->
    content = JSON.stringify object
    @post address, content, options..., on_complete

  # put a stream down the http line
  put:  (address, @options..., on_request) ->
    @once 'request', on_request
    @read_response (err, data) ->
    @send_request 'PUT', address

  # helper for http GET - returns request object
  get: (address, options..., on_connect) ->
    @once 'request', => @request.end()
    @get_stream address, options..., on_connect
  # helper for http GET - returns request object
  get_stream: (address, @options..., on_connect) ->
    @once 'connect', on_connect
    @send_request 'GET', address
 # helper to get a JSON response - in-memory so size limited
  get_json: (address, options..., on_complete) ->
    @read_response (err, data) =>
      return on_complete err if err
      return on_complete null, {} if not data?.length
      try on_complete null, JSON.parse data
      catch error then @request?.abort(); on_complete(error)
    @get address, options..., ->
  # set how many seconds we keep retrying
  retry: (seconds) -> @retry_for = seconds; return @

  fetch: (on_download_complete) ->
    return if not on_download_complete
    console.log "Downloading #{@from}..."
    to = @to; from = @from; count = 0; opts = {}
    error = (err) ->
      console.log "...failed (#{err})"
      return on_download_complete(err) if ++count >= 5
      opts["Cache-Control"] = "no-cache"
      setTimeout getter, 500
    do getter = => @get from, opts, (err) =>
      return error err if err
      dirs.mkdirs path.dirname(to), =>
        writer = fs.createWriteStream to
        streams.pipe @response, writer, =>
          files.size to, (err, size) ->
            return error err if err
            if size
              console.log '...done'
              on_download_complete()
            else
              error "empty"
    @from = @to = ''

  send_request: (method, address) ->
    if not address?.length
      address = @base
    else
      address = address[1..] if address[0] is '/'
      address = "#{@base}/#{address}" if @base?.length
    address = url.parse address, true, true
    # restore the query string - and add any from @options
    query = querystring.stringify clone.shallow \
              address.query, @_options.query
    console.log "query", query, # 5/08/2014 DELETE ME
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
    if @cookies
      c = (k+'='+v for k,v of @cookies)
      c.unshift(@options.headers.Cookie) if @options.headers.Cookie
      @options.headers.Cookie = c.join(';')
    options[key] = value for key, value of @_options
    @_options = {}
    clock = timer silent:true
    @request = null
    do requesting = =>
      @request?.abort()
      console.log "path", options.path # 5/08/2014 DELETE ME
      @request = transport.request options, (@response) =>
        status = @response.statusCode
        console.log "status", status # 5/08/2014 DELETE ME
        if status >= 300 and status < 400
          if not (to = @response.headers["location"])
            return @request.emit new Error "Bad redirect"
          to = url.resolve address.href, to
          return @send_request method, to
        @emit 'connect', null, @request, @response
      @emit 'request', @request
      @request.on 'error', (error) =>
        if error?.code is 'ECONNREFUSED' and
        clock.total() < @retry_for
          return setTimeout requesting, 500
        delete options.agent
        options = JSON.stringify options
        error = new Error(
          "#{error?.code} for #{address.href}\n#{options}")
        @emit 'connect', error, @request
        @emit 'error', error
        @removeAllListeners()

  # read response into a string for further processing
  read_response: (on_complete = ->) ->
    @once 'connect', (error) =>
      return on_complete('no response') if not @response
      if error then @request?.abort(); @emit 'error', error
      @once 'error', on_complete
      chunks = []
      @response.on 'data', dl = (chunk) -> chunks.push chunk
      @response.once 'end', =>
        if @response.headers["set-cookie"]
          for cookie in @response.headers["set-cookie"]
            [k,v] = cookie.split(';')[0].split('=')
            @cookies ?= {}
            @cookies[k] = v
        @response.removeListener 'data', dl
        @response_data = chunks.join('')
        @emit 'finish', @response_data
        on_complete null, @response_data
      
  build_url: (url, query) ->
    return "#{url}?#{querystring.stringify query}"

module.exports = Internet