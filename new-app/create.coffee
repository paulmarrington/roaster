# Copyright (C) 2013,15 paul@marrington.net, see uSDLC2/GPL for license
path = require 'path'; fs = require 'fs'; dirs = require 'dirs'
mkdirs = dirs.mkdirs; files = require 'files'

# curl 'http://localhost:9009/new-app/create.coffee?
# path=..&name=test&port=9020'
module.exports = (exchange) ->
  config = exchange.request.url.query
  config.path ?= '..'
  config.port = 9090
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
    project_dirs = ['client', 'ext', 'boot', 'config',
                    'scratch', 'scripts', 'server']
    do make_next_project_dir = ->
      return next() if project_dirs.length is 0
      mkdirs path.join(project_path, project_dirs.pop()), (error) =>
        return failure(error) if error
        make_next_project_dir()

  copy_files = (next) ->
    project_files =
      ['go.sh', 'go.bat', 'index.html',
       'boot/project-init.coffee',
       'config/base.coffee', 'config/debug.coffee',
       'config/production.coffee',
       'client/app.coffee', 'favicon.ico',
       'usdlc2/index.html', 'usdlc2/usdlc2.css']
    do copy_next_file = ->
      return next() if project_files.length is 0
      file = project_files.pop()
      source = dirs.node 'new-app', file
      target = path.join project_path, file
      fs.exists target, (exists) ->
        if exists
          copy_next_file()
        else
          files.copy source, target, (error) ->
            return failure(error) if error
            copy_next_file()

  create_roaster_scripts = (next) ->
    fs.chmod path.join(project_path, 'go.sh'), 0o700, next
  
  set_server_port = (next) ->
    return next() if config.error
    fs.appendFile path.join(
      project_path, 'config/base.coffee'),
      "  environment.port = #{config.port}\n", next

  completion = ->
    done "Project '#{config.name}' created"

  make_project_dirs ->
    copy_files ->
      create_roaster_scripts ->
        set_server_port ->
          completion()
