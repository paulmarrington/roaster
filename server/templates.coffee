# Copyright (C) 2013 Paul Marrington (paul@marrington.net), see GPL for license

# very basic string templating engine. Pattern #{key} is replaced by data element
# A function can be used if the key and arguments are separates by spaces or comma
# as in #{my_func a,1,34}
steps = require 'steps'; fs = require 'fs'

process = (template, options) ->
  return template.toString().replace /#{(.*?)}/g, (all, key) ->
  	return options[key] if key of options
  	[key, args...] = key.split /[\s,]/
  	return data[key](args...) if key of options
  	return ''

process_text = (options, processed) ->
  steps(
    -> fs.readFile options.template_name, @next (@error, @template) =>
    -> @merged = process @template, options
    -> processed(@merged)
    )

process_file = (options, done) ->
  steps(
    -> fs.readFile options.script_name, @next (@error, @script) =>
    -> options.script = @script; process_text options, @next (@merged) ->
    -> fs.writeFile options.output_name, @merged, @next
    -> done()
    )

module.exports =
  process_text: process_text
  process_file: process_file