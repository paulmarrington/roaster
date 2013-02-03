# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
require! http; require! url; require! cookies; require! 'http/driver'
require! 'http/respond'; require! 'file-system'

module.exports = (environment) ->
  return environment.server = http.createServer (request, response) ->
    console.log request.url
    request.pause!
    request.url = url.parse request.url, true
    file-system.find request.url.pathname, (filename) ->
      try
        request.filename = filename

        cookie-cutter = new cookies(request, response)
        user = cookie-cutter.get 'usdlc_session_id'
        user = environment.user if not user
        session = {user}

        # all the set up is done, process the request based on a driver
        # for file type
        exchange = {
            request, response, environment, session,
            cookies: cookie-cutter
        }
        exchange <<< {
            respond: respond(exchange),
            reply: (morph) -> exchange.respond.morph-gzip-reply(morph),
            morph: (name, next) -> next(null, name),
            post: ->
        }
        # some drivers cannot set mime type. For these we put it in the query string
        # as txt or text/plain.
        exchange.response.mimetype = request.url.query.mimetype
        # kick off exchange
        driver(exchange)
      catch error
        console.log error.stack ? error
        response.end(error.toString())
