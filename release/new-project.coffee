# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
path = require 'path'; fs = require 'fs';
mkdirs = require('dirs').mkdirs; steps = require 'steps'

# curl 'http://localhost:9009/release/new-project.coffee?path=..&name=test&port=9020'
module.exports = (exchange) ->
  config = exchange.request.url.query
  config.error = false

  project_path = path.join config.path, config.name

  done = (msg) ->
    config.result = msg
    exchange.respond.json config

  failure = (msg) ->
    config.error = true
    done error: msg.toString()

  if not config.path or not config.name
    failure 'path=.. name=MyProjectName port=9009'

  mark_error_as_failure = => @on 'error', (error) -> failure error

  make_project_dirs = =>
    dirs = 'client', 'ext', 'boot', 'config', 'scratch', 'scripts', 'server'
    make_next_project_dir = =>
      return @next() if dirs.length is 0
      mkdirs path.join(project_path, dirs.pop()), (error) =>
        @emit('error', error) if error
        make_next_project_dir()
    make_next_project_dir()

  copy_files = =>
    files = 'go', 'go.bat', 'index.html', 'app.coffee', 'app.css',
      'boot/project-init.coffee', 'config/base.coffee', 'config/debug.coffee',
      'config/production.coffee', 'client/favicon.ico'
    copy_next_file = =>
      return @next() if files.length is 0
      source = fs.node 'release', file = files.pop()
      target = path.join project_path, file
      fs.exists target, (exists) =>
        if exists
          copy_next_file()
        else
          fs.copy source, target, (error) =>
            @emit('error', error) if error
            copy_next_file()
    copy_next_file()

  create_roaster_scripts = =>
    @parallel(
      -> fs.writeFile path.join(project_path, 'ext/roaster'),
        "#!/bin/bash\n#{fs.node 'go'} $@\n", @next
      -> fs.writeFile path.join(project_path, 'ext/roaster.bat'),
        "#{fs.node 'go.bat'} %*\n", @next
      -> fs.chmod path.join(project_path, 'go'), 0o700, @next
      )

  set_server_port = =>
    if config.port
      fs.appendFile path.join(project_path, 'config/base.coffee'),
      "  environment.port = #{config.port}\n", @next
    else
      @next()

  completion = => done "Project '#{config.name}' created"

  step(
    mark_error_as_failure
    make_project_dirs
    copy_files
    create_roaster_scripts
    set_server_port
    completion
  )
