module.exports = (exchange) ->
  exchange.respond.client ->
    console.log """
    <html><body>Hello Node CLIENT</body></html>
    """
