# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
http = require 'http'; url = require 'url'; cookies = require 'cookies'
driver = require 'http/driver'; respond = require 'http/respond'
fs = require 'file-system'

module.exports = (environment) ->
  return environment.server = http.createServer (request, response) ->
    console.log request.url
    request.pause()
    request.url = url.parse request.url, true
    fs.find request.url.pathname, (filename) ->
      try
        request.filename = filename

        cookie_cutter = new cookies(request, response)
        user = cookie_cutter.get 'usdlc_session_id'
        user = environment.user if not user
        session = {user}

        # all the set up is done, process the request based on a driver
        # for file type
        exchange = {
            request, response, environment, session,
            cookies: cookie_cutter, drivers: []
        }
        exchange.respond = respond(exchange)
        # some drivers cannot set mime type. For these we put it in the query string
        # as txt or text/plain.
        if request.url.query.mimetype
            exchange.respond.set_mime_type request.url.query.mimetype
        # kick off exchange
        driver(exchange)
      catch error
        console.log error.stack ? error
        response.end error.toString()
