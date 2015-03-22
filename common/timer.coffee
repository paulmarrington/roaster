# Copyright (C) 2012,13 paul@marrington.net, see /GPL license

secondsFrom = (start) ->
  now = new Date().getTime()
  return Math.floor((now - start.getTime()) / 1000)

class Timer # Use to report elapsed times
  # Timer = require 'common/timer'
  # timer = Timer() # creates instance and prints current date
  # options.silent = true to stop logging of results
  constructor: (@options = {}) ->
    @log = (->) if @options?.silent
    @options.pre ?= ''; @options.post ?= ''
    @start = @now = new Date()
    @log "#{@now}"
  # timer.elapsed()
  # will print seconds since start or last elapsed
  elapsed: ->
    time = secondsFrom @now
    @log "#{@hms(time)} elapsed" if time > 0
    @now = new Date()
    return time
  # elapsed in ms granularity
  ms: (comment) ->
    time = (new Date().getTime() - @now.getTime()) / 1000
    @log "#{time} seconds elapsed - #{comment}"
    @now = new Date()
  # timer.total()
  # will print seconds since timer was instantiated
  total: ->
    time = secondsFrom @start
    @log "#{@hms(time)} seconds total"
    return time
  # change seconds into hours, minutes and seconds
  hms: (time) ->
    seconds = time % 60
    seconds = "0#{seconds}" if seconds < 10
    time = Math.floor(time / 60)
    minutes = time % 60
    minutes = "0#{minutes}" if minutes < 10
    hours = Math.floor(time / 60)

    hours = if hours then "#{hours}:" else ''
    return "#{hours}#{minutes}:#{seconds}"
  # display results - if needed
  log: (message) ->
    console.log "#{@options.pre}#{message}#{@options.post}"

module.exports = (options) -> new Timer(options)
