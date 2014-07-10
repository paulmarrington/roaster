# Copyright (C) 2014 paul@marrington.net, see /GPL license
cookies = require 'http/cookies'
sessions = {}

module.exports = (request, response) ->
  key = cookies.get request, 'roaster_session'
  if not key
    key = (new Date().getTime() +
           Math.floor(Math.random()*1000000000000)).toString(36)
    cookies.set response, roaster_session: key
  if not sessions[key]
    sessions[key] = user: 'guest'
  return sessions[key]