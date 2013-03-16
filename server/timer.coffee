# Copyright (C) 2012,13 Paul Marrington (paul@marrington.net), see uSDLC2/GPL for license

class Timer # Use to report elapsed times
  # Timer = require 'timer'; timer = Timer() # creates a new instance and prints current date
  # options.silent = true to stop logging of results
  constructor: (@options) ->
    @log = (->) if @options?.silent
    options.pre ?= ''; options.post ?= ''
    @start = @now = new Date()
    @log "#{@now}"
  # timer.elapsed() # will print seconds since start or last elapsed
  elapsed: ->
    time = Math.floor((new Date().getTime() - @now.getTime()) / 1000)
    @log "#{@hms(time)} elapsed" if time > 0
    now = new Date()
    return time
  # timer.total() # will print seconds since timer was instantiated
  total: ->
    time = Math.floor((new Date().getTime() - @start.getTime()) / 1000)
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
  log: (message) -> console.log "#{@options.pre}#{message}#{@options.post}"

module.exports = (options) -> new Timer(options)
