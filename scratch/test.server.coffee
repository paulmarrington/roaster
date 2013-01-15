# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

module.exports = (exchange) ->
  exchange.response.end """
  <html><body>Hello Node Servlet</body></html>
  """