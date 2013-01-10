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

http = require 'http'; url = require 'url'; respond = require 'http/respond'
os = require 'system'; Cookies = require 'cookies'
fs = require 'file-system'; driver = require 'http/driver'

# process the command line
environment = os.command_line
  port: 9009
  debug: false
  user: 'Guest'
  base_dir: fs.base ''

if environment.debug
  respond.maximum_browser_cache_age = 1000

# create a server ready to listen
server = http.createServer (request, response) ->
  console.log request.url
  request.url = url.parse request.url, true
  fs.find request.url.pathname, (filename) ->
    try
      request.filename = filename
      
      cookies = new Cookies(request, response)
      user = environment.user if not (user = cookies.get 'usdlc_session_id')
      session = {user}

      # some drivers cannot set mime type. For these we put it in the query string
      # as txt or text/plain.
      if request.url.query.mime_type
        respond.set_mime_type request.url.query.mime_type, response

      # all the set up is done, process the request based on a driver for file type
      driver(request.filename)({
        request, response, environment, session, cookies, reply: respond.static})
    catch error
      console.log error.stack ? error
      response.end(error.toString())
server.listen environment.port

console.log """
usage: go server port=#{environment.port} user=#{environment.user} debug=#{environment.debug}

uSDLC2 running on http://localhost:#{environment.port}

"""
