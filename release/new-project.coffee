# Copyright (C) 2013 paul@marrington.net, see uSDLC2/GPL for license
path = require 'path'; fs = require 'fs';
mkdirs = require('dirs').mkdirs; step = require 'step'

# curl 'http://localhost:9009/release/new-project.ls?path=..&name=test&port=9020'
module.exports = (exchange) ->
  config = exchange.request.url.query
  config.error = false

  project_path = path.join config.path, config.name

  done = (msg) ->
    config.result = msg
    exchange.respond.json config
  failure = (msg) ->
    config.error = true
    done msg

  if not config.path or not config.name
    failure 'path=.. name=MyProjectName port=9009'

  copy = (files..., next) ->
    copy_one = (error, files) ->
      return next(error) if error or files.length is 0
      file = files.pop()
      source = fs.node 'release', file
      target = path.join project_path, file
      fs.exists target, (exists) ->
        if not exists
          fs.copy source, target, (error) -> copy_one error, files
        else
          copy_one error, files
    copy_one(null, files.slice 0)

  make_project_dirs = (dirs..., next) ->
    make-one = (error, dirs) ->
      return next(error) if error or dirs.length is 0
      mkdirs path.join(project_path, dirs.pop()), (error) ->
        make-one error, dirs
    make-one null, dirs.slice 0

  step(
    ->
      @throw_errors = false
      make_project_dirs 'client', 'ext', 'boot', 'config',
                        'scratch', 'scripts', 'server', @next
    (error) ->
      @next(error) if error
      copy 'go', 'go.bat', 'index.html', 'app.coffee', 'app.css',
           'boot/project-init.coffee', 'config/base.coffee', 'config/debug.coffee',
           'config/production.coffee', 'client/favicon.ico', @next
    (error) ->
      @next(error) if error
      @parallel(
        -> fs.writeFile path.join(project_path, 'ext/roaster'),
          "#!/bin/bash\n#{fs.node 'go'} $@\n", @next
        -> fs.writeFile path.join(project_path, 'ext/roaster.bat'),
          "#{fs.node 'go.bat'} %*\n", @next
        -> fs.chmod path.join(project_path, 'go'), 8~700, @next
        ->
          if config.port
            fs.appendFile path.join(project_path, 'config/base.coffee'),
            "  environment.port = #{config.port}\n", @next
      )
    (error) ->
      return failure(error) if error
      done "Project '#{config.name}' created"
  )
