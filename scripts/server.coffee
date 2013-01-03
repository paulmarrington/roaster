# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

# Create a HTTP server that processes requests based on the extension (being
# the characters after the final dot) - defaulting to 'html'. These drivers
# are modules in server/http/ext with a name that matches the extension. In 
# other words, html.coffee will be loaded to process index.html. The driver
# modules return a function that is called on each HTTP request and passed
# an exchange object consisting of

#   request: a node http.ServerRequest object
#       (http://nodejs.org/api/http.html#http_class_http_serverrequest)
#   response: a node http.ServerResponse object
#       (http://nodejs.org/api/http.html#http_class_http_serverresponse)
#   cookies: a lazy cookie loader and saver
#       (https://github.com/jed/cookies)
#   environment: an object common to all http conversations on this server.
#     port: The port number this server listens on
#     debug: If true errors close server with a stack dump
#     user: Default user if no-one has logged in
#   session: an object common to a single browser conversation set
#     user: Object containing details for a guest or logged in user

http = require 'http'; url = require 'url'; path = require 'path'
os = require 'operating-system'; static_driver = require 'http/respond'
Cookies = require 'cookies'; send = require 'send'

# process the command line
environment = os.command_line
  port: 9009
  debug: false
  user: 'Guest'
  base_dir: process.env.uSDLC_base_path

if environment.debug # allow an exception to kill the server - with a stack trace
  process_request = (action) -> action()
else # while for production we just log the message and go for a new request
  process_request = (action) -> 
    try action() catch error then console.log error

# create a server ready to listen
server = http.createServer (request, response) ->
  try
    console.log request.url
    request.url = url.parse request.url
    basename = path.basename(request.url.pathname)
    dot = basename.indexOf('.') + 1
    ext = if dot then basename[dot..] else 'html'
    request.filename = "#{process.env.uSDLC_base_path}#{request.url.pathname}"
    
    cookies = new Cookies(request, response)
    user = environment.user if not (user = cookies.get 'usdlc_session_id')
    session = {user}

    driver_module_name = "http/ext/#{ext}"

    load_driver = (ext, try_next) ->
      driver_module_name = "http/ext/#{ext}"
      try
        return require driver_module_name
      catch error
        if error.toString().indexOf("'#{driver_module_name}'") isnt -1
          return try_next()
        else
          throw error

    driver_module = load_driver ext, ->
      exts = ext.split('.')
      return null if exts.length < 2
      response.setHeader "Content-Type", send.mime.lookup exts[0]
      load_driver exts[1..].join('.'), -> null
    # default to cached send if no special handling requested
    driver_module ?= require.cache[driver_module_name] = static_driver

    # all the set up is done, process the request
    driver_module {request, response, environment, session, cookies}
  catch error
    console.log error.stack ? error
    response.end(error.toString())
    
server.listen environment.port

console.log """
usage: go server port=#{environment.port} user=#{environment.user} debug=#{environment.debug}

uSDLC2 running on http://localhost:#{environment.port}

"""
