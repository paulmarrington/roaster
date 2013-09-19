# Copyright (C) 2013 paul@marrington.net, see GPL for license

# very basic string templating engine. Pattern #{key}
# is replaced by data element A function can be used
# if the key and arguments are separates by spaces or comma
# as in #{my_func a,1,34}
steps = require 'steps'; fs = require 'fs'
files = require 'files'

process = (template, options) ->
  return template.toString().replace /#{(.*?)}/g, (all, key) ->
    return options[key] if key of options
    [key, args...] = key.split /[\s,]/
    return data[key](args...) if key of options
    return ''

process_text = (options, processed) ->
  steps(
    ->  files.find options.template_name, @next (@template_name) ->
    ->  if not @template_name then processed(null); @abort()
    ->  fs.readFile @template_name, @next (@error, @template) ->
    ->  @merged = process @template, options
    ->  processed(@merged)
    )

process_file = (options, done) ->
  steps(
    ->  files.find options.script_name @next @script_name
    ->  fs.readFile @script_name, @next (@error, @script) =>
    ->  options.script = @script; process_text options, @next (@merged) ->
    ->  fs.writeFile options.output_name, @merged, @next
    ->  done()
    )

module.exports =
  process_text: process_text
  process_file: process_file
