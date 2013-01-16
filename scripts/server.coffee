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
#   respond: method to call to send data back to the browser - chaining support

create_http_server = require 'boot/create-http-server'
create_faye_server = require 'boot/create-faye-server'
project_init = require 'boot/project-init'
respond = require 'http/respond'
os = require 'system'; fs = require 'file-system'

# process the command line
environment = os.command_line
  port: 9009
  debug: false
  user: 'Guest'
  base_dir: fs.base ''

respond.maximum_browser_cache_age = 1000 if environment.debug

# allow project to tweak settings before we commit to action
project_init.pre environment

# create a server ready to listen
environment.server = create_http_server environment
environment.faye = create_faye_server environment

# kick-off
environment.server.listen environment.port
# lastly we do more project level initialisation
project_init.post environment

console.log """
usage: go server port=#{environment.port} user=#{environment.user} debug=#{environment.debug}

uSDLC2 running on http://localhost:#{environment.port}

"""
