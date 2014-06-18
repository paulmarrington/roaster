# Copyright (C) 2014 paul@marrington.net, see /GPL license
cookies = require 'http/cookies'
sessions = {}; now = new Date().getTime()
seed = ->
  (now + Math.floor(Math.random()*1000000000000)).toString(36);

module.exports = (request, response) ->
  key = cookies.get request, 'roaster_session'
  if not key or not sessions[key]
    key = seed();
    cookies.set response, roaster_session: key
    sessions[key] = user: 'guest'
  return sessions[key]