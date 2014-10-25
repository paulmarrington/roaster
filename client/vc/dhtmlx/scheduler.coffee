# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'Integrant'
requires = (ready) ->
  require.packages 'dhtmlx/scheduler', ready

class Scheduler extends Integrant
  init: (done) -> requires (imports) =>
   scheduler.init @host, new Date(), 'week'
    
module.exports = Scheduler