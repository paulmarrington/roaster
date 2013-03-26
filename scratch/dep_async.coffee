module.exports = (exchange) ->
  exchange.respond.client ->
    module.exports  'dep-async-1 result'
