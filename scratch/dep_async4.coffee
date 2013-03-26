module.exports = (exchange) ->
  exchange.respond.client -> (error, next) ->
    module.exports 'dep-async-4 result'
