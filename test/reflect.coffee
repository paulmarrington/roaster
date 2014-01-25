module.exports = (exchange) ->
  console.log "REFLECT",exchange.request.url.query
  exchange.respond.json
    error: false
    question: exchange.request.url.query.question