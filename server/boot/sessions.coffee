# Copyright (C) 2014 paul@marrington.net, see /GPL license
cookies = require 'http/cookies'
sessions = {}; now = new Date().getTime()
seed = ->
  (now + Math.floor(Math.random()*1000000000000)).toString(36);

module.exports = (request, response) ->
  if not (key = cookies.get request, 'roaster-session')
    key = seed();
    cookies.set 'roaster-session', key
    sessions[key] = user: 'guest'
  return sessions[key]