# Copyright (C) 2014 paul@marrington.net, see /GPL license
Integrant = require 'Integrant'

class Scheduler extends Integrant
  init: (done) -> require.packages 'dhtmlx/scheduler', ->
    scheduler.init @host, new Date(), 'week'
    done()
    
module.exports = Scheduler