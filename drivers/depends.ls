# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

# called by depends.coffee from the client. It is expecting a script that
# compiles to java-script. It wraps the resultint code in a function as
# expected by the server before sending it back using the original reply
# mechanism
require! 'morph/wrap'

module.exports = (exchange, next) ->
  before = "#{exchange.request.url.query.global_var}=function(module){"
  after =  ';}'
  exchange.respond.morph wrap('.depends', before, after), next
