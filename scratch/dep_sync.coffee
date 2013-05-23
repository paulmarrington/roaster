module.exports = (exchange) ->
  exchange.respond.client ->
    module.exports = 'dep-sync result'
