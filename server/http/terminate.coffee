# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

# curl http://localhost:9009/server/http/terminate?exit_code = 1
module.exports = (exchange) -> process.exit exchange.request.url.query.exit_code ? 0