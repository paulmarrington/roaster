# Copyright (C) 2013,15 paul@marrington.net, see uSDLC2/GPL for license
path = require 'path'; fs = require 'fs'; dirs = require 'dirs'
mkdirs = require('dirs').mkdirs; files = require 'files'

# curl 'http://localhost:9009/new-app/create.coffee?
# path=..&name=test&port=9020'
module.exports = (exchange) ->
  config = exchange.request.url.query
  config.path ?= '..'
  config.port = 9009
  config.error = false

  project_path = path.join config.path, config.name

  done = (msg) ->
    config.result = msg
    exchange.respond.json config

  failure = (msg) ->
    config.error = true
    done error: msg.toString()

  if not config.name
    failure 'path=.. name=MyProjectName port=9009'

  make_project_dirs = (next) ->
    dirs = ['client', 'ext', 'boot', 'config',
            'scratch', 'scripts', 'server']
    do make_next_project_dir = ->
      return next() if dirs.length is 0
      mkdirs path.join(project_path, dirs.pop()), (error) =>
        return failure(error) if error
        make_next_project_dir()

  copy_files = (next) ->
    files = ['go', 'go.bat', 'index.html',
             'boot/project-init.coffee',
             'config/base.coffee', 'config/debug.coffee',
             'config/production.coffee',
             'client/favicon.ico']
    do copy_next_file = (next) ->
      return next() if files.length is 0
      source = dirs.node 'new-app', file = files.pop()
      target = path.join project_path, file
      fs.exists target, (exists) ->
        if exists
          copy_next_file()
        else
          files.copy source, target, (error) ->
            return failure(error) if error
            copy_next_file()

  create_roaster_scripts = (next) ->
    return next()
  
  set_server_port = (next) ->
    return if config.error
    if config.port
      fs.appendFile path.join(
        project_path, 'config/base.coffee'),
        "  environment.port = #{config.port}\n", next
    else
      next()

  completion = ->
    done "Project '#{config.name}' created"

  mark_error_as_failure ->
    make_project_dirs ->
      copy_files ->
        create_roaster_scripts ->
          set_server_port ->
            completion
