# Copyright (C) 2013 paul@marrington.net, see GPL for license

# very basic string templating engine. Pattern #{key}
# is replaced by data element A function can be used
# if the key and arguments are separates by spaces or comma
# as in #{my_func a,1,34}
fs = require 'fs'; files = require 'files'

process = (template, options) ->
  return template.toString().replace /#{(.*?)}/g, (all, key) ->
    return options[key] if key of options
    [key, args...] = key.split /[\s,]/
    return data[key](args...) if key of options
    return ''

process_text = (options, done) ->
  files.find options.template_name, (template_path) ->
    return done() if not template_path
    fs.readFile template_path, (err, template) ->
      return done() if err
      done process template, options

process_file = (options, done) ->
  files.find options.script_name, (script_path) ->
    return done("No #{script_name}") if not script_path
    fs.readFile script_path, (err, script) ->
      return done(err) if err
      options.script = script
      process_text options, (merged) ->
        fs.writeFile options.output_name, merged, done

module.exports =
  process_text: process_text
  process_file: process_file
