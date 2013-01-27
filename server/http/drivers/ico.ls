# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license
respond = require 'http/respond'

modules.export = (exchange) ->
  filename = request.url.pathname
  if filename is '/favicon.ico'
    exchange.request.filename = "#{exchange.environment.base_dir}/client/favicon.ico"
  respond.static exchange
