# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
http = require 'http'; url = require 'url'
Cookies = require 'cookies'; driver = require 'http/driver'
respond = require 'http/respond'; fs = require 'file-system'

module.exports = (environment) ->
  return environment.server = http.createServer (request, response) ->
    console.log request.url
    request.pause()
    request.url = url.parse request.url, true
    fs.find request.url.pathname, (filename) ->
      try
        request.filename = filename

        cookies = new Cookies(request, response)
        user = environment.user if not (user = cookies.get 'usdlc_session_id')
        session = {user}

        # all the set up is done, process the request based on a driver
        # for file type
        exchange = {request, response, environment, session, cookies}
        exchange.reply = -> respond.static exchange
        exchange.morph = (name, next) -> next null, name
        # some drivers cannot set mime type. For these we put it in the query string
        # as txt or text/plain.
        exchange.response.mimetype = request.url.query.mimetype
        # kick off exchange
        driver(request.filename)(exchange)
      catch error
        console.log error.stack ? error
        response.end(error.toString())
